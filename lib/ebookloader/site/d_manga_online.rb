module EBookloader
    class Site
        class DMangaOnline < Site
            def initialize identifier, name = nil
                super "http://d-manga.dengeki.com/work/#{identifier}/", name
            end

            private
            def lazy_load
                source = get @uri
                source.body.force_encoding Encoding::UTF_8

                if @name.nil?
                    match = source.body.match %r{<h2 class="workTextTtl">\s*?<img[^>]*alt="(?<title>[^"]*?)">\s*?</h2>\s*?<p class="workTextAuthor">\s*?著者名： (?<author>.*?)\s*?</p>}m
                    author = Site.get_author match[:author]
                    title = match[:title]
                    @name = '[%s] %s' % [author, title]
                end

                source.body.match %r{<ul class="workList backnumber">(?<list>.*?)</ul>(?:.*?<ul class="workList extra">(?<extra>.*?)</ul>)?}m do |match|
                    extra = match[:extra] || ''
                    extra.gsub! '<a ', '番外編<a '
                    @books = lazy_collection (extra + match[:list]), %r{<li>(?<extra>.*?)<a href="(?<uri>.*?)" target="_blank">(?<episode_num>[^<]*?)</a></li>}m, true do |sc|
	                    uri = @uri + sc[:uri]
                        format = sc[:extra].empty? ? '%1$s %2$s' : '%1$s %3$s %2$s'
	                    name = (format % [@name, Site.get_episode_number(sc[:episode_num]), sc[:extra]]).strip
	                    Book::ActiBook.new(uri, name: name, headers: {'Referer' => uri.to_s})
	                end
	            end

                true
            end
        end
    end
end
