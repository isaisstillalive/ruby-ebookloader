# coding: utf-8

module EBookloader
  module Book
    class EasyEPaperViewer < Base
      include Book::MultiplePages
      require 'rexml/document'

      private

      def lazy_load
        query = Hash[URI.decode_www_form @uri.query] rescue {}
        base_uri = @uri + "./#{query['id']}/"

        configue_uri = base_uri + './config.xml'
        xml = get configue_uri
        doc = REXML::Document.new xml.body

        update_without_overwrite title: doc.text('/config/title'), author: doc.text('/config/author')

        page_count = doc.text('/config/number').to_i
        @pages = (1..page_count).map do |page|
          Page.new base_uri + './img%02d.jpg' % page, page: page
        end

        true
      end
    end
  end
end
