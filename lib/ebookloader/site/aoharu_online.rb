module EBookloader
    class Site
        class AoharuOnline < Site
            def initialize identifier, name = nil
                super "http://aoharu.jp/#{identifier}/", name
            end

            private
            def lazy_load
                source = get @uri
                source.body.force_encoding Encoding::UTF_8

                if @name.nil?
                    match = source.body.match %r{<h2 id="summary-title">\s*?<span class="ttl1">(?<title>[^<]*?)</span>\s*?<span class="ttl2">(?<author>[^<]*?)</span></h2>}m
                    author = match[:author]
                    title = match[:title]
                    @name = '[%s] %s' % [author, title]
                end

                @books = lazy_collection source.body, %r{<li class="card mod-s">.*?<a href="(?<uri>.*?)" class="card-togo">\s*<span class="title2">(?<episode_num>[^<]*?)</span>(?:\s*<span class="title">(?<episode>[^<]*?)</span>)?\s*</a>|<li>\s*<a href="(?<uri>[^"]*?)">\s*<span class="bitsy-stl">(?<episode_num>[^<]*?)</span>(?:\s*<span class="bitsy-ttl">(?<episode>[^<]*?)</span>)?\s*</a>\s*</li>}m, true do |sc|
                    uri = @uri + sc[:uri]
                    name = ('%s %s %s' % [@name, Site.get_episode_number(sc[:episode_num]), sc[:episode]]).strip
                    Book::Aoharu.new(uri, name)
                end

                true
            end
        end
    end
end
