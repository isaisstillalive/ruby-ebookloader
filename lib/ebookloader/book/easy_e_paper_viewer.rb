# coding: utf-8

module EBookloader
  class Book
    class EasyEPaperViewer < Book
      include Book::MultiplePages
      require 'rexml/document'

      private

      def lazy_load
        query = Hash[URI.decode_www_form @uri.query] rescue {}
        base_uri = @uri + "./#{query['id']}/"

        configue_uri = base_uri + './config.xml'
        xml = get configue_uri
        doc = REXML::Document.new xml.body

        merge title: doc.elements['/config/title'].text, author: doc.elements['/config/author'].text

        page_count = doc.elements['/config/number'].text.to_i
        @pages = (1..page_count).map do |page|
          Page.new base_uri + './img%02d.jpg' % page, page: page
        end

        true
      end
    end
  end
end
