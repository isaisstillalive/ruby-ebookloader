module EBookloader
    class Book
        class ActiBook < Book
            include Book::MultiplePages
            require 'rexml/document'

            private
            def lazy_load
                configue_uri = @uri + './books/db/book.xml'
                xml = get configue_uri
                doc = REXML::Document.new xml.body

                @name ||= doc.elements['/book/name'].text

                @pages = doc.to_enum(:each_element, '/book/pages/page').lazy.map do |page|
                    uri = @uri + "./books/images/2/#{page.elements['number'].text}.#{page.elements['type'].text}"
                    filename = '%03d.%s' % [page.elements['ActiBookPageNumber'].text, page.elements['type'].text]
                    [filename, uri]
                end

                true
            end
        end
    end
end
