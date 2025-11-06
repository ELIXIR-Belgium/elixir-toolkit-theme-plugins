require "jekyll"
require "set"

module Jekyll
    class Ett
        module ToolTableFilter
        def add_related_pages(data)
            load_page_data

            for tool in data
            if tool['id'] && @related_pages[tool['id']]
                tool['related_pages'] = @related_pages[tool['id']].to_a
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

            if page_id_matches
                page_id = page_id_matches[1]
                file.scan(/\{%\s*tool\s*"([^"]+)"\s*%}/).flatten.each do |m|
                @related_pages[m] = Set[] unless @related_pages[m]
                @related_pages[m].add(page_id)
                end
            end
            end
        end
        end
    end
    Liquid::Template.register_filter(Jekyll::Ett::ToolTableFilter)
end
