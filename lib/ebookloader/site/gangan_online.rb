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

                self.merge! source.body.match(%r{<h2 class="iepngFixBg">(?<title>.*?)\s*<span class="titleYomi">\s*\((.*?)\)</span></h2>})

                source.body.match %r{<ul id="contentCenterBknmbrList">.*?</ul>}m do |match|
                    @books = lazy_collection source.body, %r{<li[^>]*?>【(?<episode_num>[^】]*?)】(?<episode>.*?)：<a [^>]*?onclick="javascript:Fullscreen\('(?<uri>[^']*?)'\);"[^>]*?>PC</a>} do |sc|
                        uri = @uri + sc[:uri]
                        name = '%s %s %s' % [self.name, sc[:episode_num], sc[:episode]]
                        Book::ActiBook.new(uri, name: name)
                    end
                end

                true
            end
        end
    end
end
