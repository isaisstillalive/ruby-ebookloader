# coding: utf-8

module EBookloader
    class Book
        class Togetter < Book
            include Book::MultiplePages

            private
            
            def lazy_load
                source = get @uri
                source.body.force_encoding Encoding::UTF_8

                if @name.nil?
                    match = source.body.match(%r{<h1>\s*<a class="info_title" href="[^"]*" title="(?<title>[^"]*)"}m)
                    @name = match[:title]
                end

                id = @uri.to_s.match(%r{^http://togetter\.com/li/(?<id>[^/]*)})[:id]
                csrf_token = source.body.match(%r{<meta name="csrf_token" content="(?<csrf_token>[^"]*)"/>})[:csrf_token]
                tweets = get URI("http://togetter.com/api/moreTweets/#{id}?page=1&csrf_token=#{csrf_token}")
                tweets.body.force_encoding Encoding::UTF_8
                body = tweets.body

                @pages = body.to_enum(:scan, %r{<div class='list_photo'><a[^>]*?><img src="([^"]*)" /></a></div>}m).lazy.map do |sc|
                    Page.new(URI(sc[0] + ':large'), extension: Pathname(sc[0]).extname[1..-1].to_sym)
                end

                true
            end
        end
    end
end
