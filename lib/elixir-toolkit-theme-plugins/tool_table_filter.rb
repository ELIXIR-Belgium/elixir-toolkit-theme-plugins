require "jekyll"
require "set"

module Jekyll
    class Ett
        module ToolTableFilter
            def add_related_pages(data)
                return [] if data.nil?
                return data unless data.is_a?(Array)

                load_page_data

                data.each do |tool|
                    next unless tool.is_a?(Hash)

                    if tool["id"] && @related_pages[tool["id"]]
                        tool["related_pages"] = @related_pages[tool["id"]].to_a
                    end
                end

                data
            end

            private

            def load_page_data
                @related_pages = {}
                pages_path = File.join(Dir.pwd, "**", "*.md")

                Dir.glob(pages_path).each do |f|
                    file = File.read(f)
                    page_id_matches = file.match(/page_id:\s*(\w+)/)

                    next unless page_id_matches

                    page_id = page_id_matches[1]

                    file.scan(/\{%\s*tool\s*"([^"]+)"\s*%}/).flatten.each do |m|
                        @related_pages[m] ||= Set.new
                        @related_pages[m].add(page_id)
                    end
                end
            end
        end
    end

    Liquid::Template.register_filter(Jekyll::Ett::ToolTableFilter)
end
