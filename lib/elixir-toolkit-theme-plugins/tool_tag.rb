require "jekyll"
require "yaml"

module Jekyll
    class Ett
        class ToolTag < Liquid::Tag
        def initialize(tagName, content, tokens)
            super
            @content = content
            load_tools
            load_instances
        end

        def load_tools
            tools_path = File.join(Dir.pwd, "_data", "tool_and_resource_list.yml")
            @tools = YAML.load(File.read(tools_path))
        end
        
        # Scan Markdown pages for front matter declaring national_resources
        # and index instances by their "instance_of" tool id
        def load_instances
        # Single combined index for *all* instances
        @instances_by_tool = Hash.new { |h, k| h[k] = [] }

        # --- 1) instances from national_resources in page front matter ---
        pages_path = File.join(Dir.pwd, "**", "*.md")
        files = Dir.glob(pages_path)

        files.each do |f|
            raw = File.read(f)
            fm = extract_front_matter(raw)
            next unless fm.is_a?(Hash)

            country_code  = (fm["country_code"] || "").to_s
            country_name  = (fm["title"] || "").to_s
            resources     = fm["national_resources"] || []
            next unless resources.is_a?(Array)

            resources.each do |res|
                next unless res.is_a?(Hash)
                inst_of = res["instance_of"]
                next if inst_of.nil? || inst_of == "NA"

                @instances_by_tool[inst_of] << {
                    "name"         => (res["name"] || res["id"] || "Instance"),
                    "url"          => res["url"],
                    "id"           => res["id"],
                    "country_code" => country_code,
                    "country_name" => country_name,
                    "page_path"    => f
                }
            end
        end

        # --- 2) instances from tool_and_resource_list.yml itself ---
        (@tools || []).each do |tool|
            parent_id = tool["instance_of"]
            next if parent_id.nil? || parent_id == "NA"

            @instances_by_tool[parent_id] << {
                "name"         => (tool["name"] || tool["id"] || "Instance"),
                "url"          => tool["url"], # normally defined for tools
                "id"           => tool["id"],
                # YAML entries often don’t have country information; leave blank so no flag
                "country_code" => "",
                "country_name" => "",
                "page_path"    => nil # no page file to resolve
                }
            end
        end


        # Accepts a file string, returns parsed YAML front matter hash or nil
        def extract_front_matter(file_string)
            if file_string =~ /\A---\s*\n(.*?)\n---\s*\n/m
            yaml = Regexp.last_match(1)
            YAML.safe_load(yaml, permitted_classes: [Date, Time], aliases: true)
            else
            nil
            end
        rescue
            nil
        end

        def render(context)
            site = context.registers[:site]
            tool_id_from_liquid = context[@content.strip]
            tool = find_tool(tool_id_from_liquid)
            tags = create_tags(tool, site)
            %Q{<a
                tabindex="0"
                class="tool"
                aria-description="#{html_escape(tool["description"])}"
                data-bs-toggle="popover"
                data-bs-placement="bottom"
                data-bs-trigger="focus"
                data-bs-content="<h5>#{html_escape(tool["name"])}</h5><div class='mb-2'>#{html_escape(tool["description"])}</div><div class='d-flex flex-wrap gap-1'>#{tags}</div>"
                data-bs-template="<div class='popover popover-tool' role='tooltip'><div class='popover-arrow'></div><h3 class='popover-header'></h3><div class='popover-body'></div></div>"
                data-bs-html="true"
                ><i class="fa-solid fa-wrench fa-sm me-2"></i>#{ html_escape(tool["name"]) }</a>}
        end

        def find_tool(tool_id)
            tool = @tools.find { |t| t["id"] == tool_id.strip }
            return tool if tool
            raise Exception.new "Undefined tool ID: #{tool_id}"
        end

        def create_tags(tool, site)
            tags = ""
            tags << create_tag("#{tool["url"]}", "fa-link", "Website")
            if tool["registry"]
            registry = tool["registry"]
            tags << create_tag("https://bio.tools/#{registry["biotools"]}", "fa-info", "Tool info") if registry["biotools"] && registry["biotools"] != "NA"
            tags << create_tag("https://fairsharing.org/FAIRsharing.#{registry["fairsharing"]}", "fa-database", "Standards/Databases") if registry["fairsharing"] && registry["fairsharing"] != "NA"
            tags << create_tag("https://fairsharing.org/#{registry["fairsharing-coll"]}", "fa-database", "Standards/Databases") if registry["fairsharing-coll"] && registry["fairsharing-coll"] != "NA"
            tags << create_tag("https://tess.elixir-europe.org/search?q=#{registry["tess"]}", "fa-graduation-cap", "Training") if registry["tess"] && registry["tess"] != "NA"
            tags << create_tag("https://europepmc.org/article/MED/#{registry["europmc"]}", "fa-book", "Publication") if registry["europmc"] && registry["europmc"] != "NA"
            end

            instances = @instances_by_tool[tool["id"]]
            tags << instances_dropdown(instances, site, tool["id"]) if instances && !instances.empty?
            tags
        end

        def create_tag(url, icon, label)
            "<a href='#{html_attr(url)}' target='_blank' rel='noopener'><span class='badge bg-dark text-white hover-primary'><i class='fa-solid #{icon} me-2'></i>#{html_escape(label)}</span></a>"
        end

        def instances_dropdown(instances, site, tool_id)
            dd_id = "instances-dd-#{tool_id}-#{object_id}"

            items = instances.map do |inst|
            href = inst["url"] || resolve_page_url(inst["page_path"], site) || "#"
            flag = inst["country_code"].to_s.strip.empty? ? "" : "<span class='flag-icon ms-2 shadow-sm flag-icon-#{inst["country_code"].downcase}'></span>"
            name = html_escape(inst["name"])
            url  = html_attr(href)
            "<li><a class='dropdown-item' href='#{url}' target='_blank' rel='noopener'>#{name} #{flag}</a></li>"
            end.join

            %Q{
            <div class='dropdown d-inline-block'>
                <button class='btn btn-badge btn-outline-primary dropdown-toggle'
                        type='button'
                        id='#{dd_id}'
                        data-bs-toggle='dropdown'
                        aria-expanded='false'>
                <i class='fa-solid fa-globe me-2'></i>Instances
                </button>
                <ul class='dropdown-menu' aria-labelledby='#{dd_id}'>
                #{items}
                </ul>
            </div>
            }
        end

        # Resolve a site-relative URL from an absolute file path stored in page_path
        def resolve_page_url(abs_path, site)
            return nil unless abs_path && site
            rel = abs_path.sub(%r{\A#{Regexp.escape(Dir.pwd)}/?}, "")
            doc = (site.pages + site.collections.values.flat_map(&:docs)).find { |p| p.path == rel }
            doc&.url
        rescue
            nil
        end

        # --- escaping helpers ---

        def html_escape(s)
            (s || "").to_s.gsub("&","&amp;").gsub("<","&lt;").gsub(">","&gt;").gsub('"',"&quot;")
        end

        def html_attr(s)
            html_escape(s).gsub("'","&#39;")
        end
        end
    end
    Liquid::Template.register_tag("tool", Jekyll::Ett::ToolTag)
end
