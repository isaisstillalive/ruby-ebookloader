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

                @books = source.body.to_enum(:scan, /<div class="totalinfo">\s*<div class="eachStoryText">\s*<h4>([^<]*?)<\/h4>.*?<a target="_new" href="([^""]*?)">読む<\/a>/m).lazy.reverse_each.map do |sc|
                    uri = @uri + sc[1]
                    name = '%s %s' % [@name, sc[0]]
                    Book::ActiBook.new(uri, name)
                end

                true
            end
        end
    end
end
