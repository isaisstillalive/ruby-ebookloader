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

                @books = source.body.to_enum(:scan, /<li><a href="([^"]*)" class="openViewer".*?<figcaption><strong>(.*?)<\/strong>(.*?)<\/figcaption>/m).lazy.map do |sc|
                    uri = @uri + sc[0]
                    
                    story = sc[1]
                    story.gsub! /（.*?）/, ''

                    name = '%s %s %s' % [@name, story, sc[2]]
                    Book::AkitashotenReadingCommunicator.new(uri, name)
                end

                true
            end
        end
    end
end