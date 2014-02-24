# coding: utf-8

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

        page_count = doc.elements['/book/total'].text.to_i
        @pages = doc.to_enum(:each_element, '/book/pages/page'){ page_count }.lazy.map do |page|
          @uri + "./books/images/2/#{page.elements['number'].text}.#{page.elements['type'].text}"
        end

        true
      end
    end
  end
end
