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

                self.merge! source.body.match(%r{<header><h1><strong>(?<title>.*?)</strong> ／ (?<author>.*?)</h1></header>})

                @books = lazy_collection source.body, %r{<li><a href="(?<uri>[^"]*)" class="openViewer".*?<figcaption><strong>(?<episode_num>.*?)（[^）]*?）</strong>(?<episode>.*?)</figcaption>}m, true do |sc|
                    uri = @uri + sc[:uri]
                    
                    name = '%s %s %s' % [self.name, sc[:episode_num], sc[:episode]]
                    Book::AkitashotenReadingCommunicator.new(uri, name: name)
                end

                true
            end
        end
    end
end