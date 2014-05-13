# coding: utf-8

module EBookloader
  module Book
    class ActiBook < Base
      include Book::MultiplePages
      require 'rexml/document'

      private

      def lazy_load
        configue_uri = @uri + './books/db/book.xml'
        xml = get configue_uri
        doc = REXML::Document.new xml.body

        update_without_overwrite title: doc.text('/book/name')

        zoom = doc.get_elements('/book/PageSizes/PageSize').map{|element| element.attribute('zoom').to_s.to_f }.max

        @pages = doc.get_elements('/book/pages/page').map do |page|
          page_number = page.text('number')
          extension = page.text('type')
          Page.new @uri + "./books/images/#{zoom}/#{page_number}.#{extension}", options.merge(page: page_number.to_i, extension: extension.to_sym)
        end

        true
      end
    end
  end
end
