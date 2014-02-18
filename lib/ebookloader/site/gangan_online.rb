module EBookloader
    class Site
        class GanganOnline < Site
            def initialize identifier, name = nil
                super "http://www.ganganonline.com/comic/#{identifier}/", name
            end

            private
            def lazy_load
                source = get @uri
                source.body.encode! Encoding::UTF_8, Encoding::Shift_JIS

                @name ||= source.body.match(/<h2 class="iepngFixBg">(.*?) <span class="titleYomi">\((.*?)\)<\/span><\/h2>/)[1]

                @books = source.body.to_enum(:scan, /<li(?: class="last")?>【([^】]*?)】(.*?)：<a href="javascript:void\(0\);" onclick="javascript:Fullscreen\('([^']*?)'\);">PC<\/a>.*?<\/li>/m).lazy.map do |sc|
                    uri = @uri + sc[2]
                    name = '%s %s %s' % [@name, sc[0], sc[1]]
                    Book::ActiBook.new(uri, name)
                end

                true
            end
        end
    end
end
