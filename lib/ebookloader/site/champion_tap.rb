module EBookloader
    class Site
        class ChampionTap < Site
            def initialize identifier, name = nil
                super "http://tap.akitashoten.co.jp/comics/#{identifier}/", name
            end

            private
            def lazy_load
                source = get @uri
                source.body.force_encoding Encoding::UTF_8

                if @name.nil?
                    match = source.body.match /<header><h1><strong>(.*?)<\/strong> ／ (.*?)<\/h1><\/header>/
                    author = match[2]
                    title = match[1]
                    @name = '[%s] %s' % [author, title]
                end

                @books = lazy_collection source.body, /<li><a href="(?<uri>[^"]*)" class="openViewer".*?<figcaption><strong>(?<episode_num>.*?)（[^）]*?）<\/strong>(?<episode>.*?)<\/figcaption>/m, true do |sc|
                    uri = @uri + sc[:uri]
                    
                    name = '%s %s %s' % [@name, sc[:episode_num], sc[:episode]]
                    Book::AkitashotenReadingCommunicator.new(uri, name)
                end

                true
            end
        end
    end
end