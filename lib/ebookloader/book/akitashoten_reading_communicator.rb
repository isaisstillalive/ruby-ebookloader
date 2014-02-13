# coding: utf-8

module EBookloader
    class Book
        class AkitashotenReadingCommunicator < Book
            include Book::MultiplePages

            private
            
            def lazy_load
                source = get @uri
                source.body.force_encoding Encoding::UTF_8

                if @name.nil?
                    match = source.body.match /<h1 title="(?<title>.*?) ">.*?<span id="author" title="(?<author>.*?)">/m
                    @name = '[%s] %s' % [match[:author], match[:title]]
                end

                match = source.body.match /ARC.Comic = (\{.*?url: '(?<image_path>[^']*)'.*?page_count: (?<page_count>\d*).*?\})/m
                image_path = match[:image_path]
                page_count = match[:page_count].to_i

                @pages = (1..page_count).to_enum{ page_count }.lazy.map do |page|
                    uri = @uri + "#{image_path}/#{page}"
                    filename = '%03d.%s' % [page, 'jpg']
                    [filename, uri]
                end

                true
            end
        end
    end
end
