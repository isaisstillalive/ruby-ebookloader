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

        merge title: doc.elements['/book/name'].text

        @pages = doc.get_elements('/book/pages/page').map do |page|
          page_number = page.elements['number'].text
          extension = page.elements['type'].text
          Page.new @uri + "./books/images/2/#{page_number}.#{extension}", page: page_number.to_i, extension: extension.to_sym
        end

        true
      end
    end
  end
end
