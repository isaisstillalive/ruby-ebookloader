module EBookloader
    class Site
        class ComicMeteor < Site
            def initialize identifier, name = nil
                super "http://comic-meteor.jp/#{identifier}/", name
            end

            private

            def lazy_load
                source = get @uri
                source.body.force_encoding Encoding::UTF_8

                if @name.nil?
                    authors = source.body.scan(/<h4 class="tit_04">.*?：(.*?)<\/h4>/m)
                    author = authors.flatten.join ', '
                    title = source.body.match(/<h2 class="h2Title">(.*?)<\/h2>/m)[1]
                    @name = '[%s] %s' % [author, title]
                end

                @books = lazy_collection source.body, /<div class="totalinfo">\s*<div class="eachStoryText">\s*<h4>(?<episode>[^<]*?)<\/h4>.*?<a target="_new" href="(?<uri>[^""]*?)">読む<\/a>/m, true do |sc|
                    uri = @uri + sc[:uri]
                    name = '%s %s' % [@name, sc[:episode]]
                    Book::ActiBook.new(uri, name)
                end

                true
            end
        end
    end
end
