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

                if @name.nil?
                    @name = source.body.match(/<h2 class="iepngFixBg">(?<title>.*?) <span class="titleYomi">\((.*?)\)<\/span><\/h2>/)[:title]
                end

                @books = lazy_collection source.body, /<li(?: class="last")?>【(?<episode_num>[^】]*?)】(?<episode>.*?)：<a href="javascript:void\(0\);" onclick="javascript:Fullscreen\('(?<uri>[^']*?)'\);">PC<\/a>.*?<\/li>/m do |sc|
                    uri = @uri + sc[:uri]
                    name = '%s %s %s' % [@name, sc[:episode_num], sc[:episode]]
                    Book::ActiBook.new(uri, name)
                end

                true
            end
        end
    end
end
