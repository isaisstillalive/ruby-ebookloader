# coding: utf-8

module EBookloader
  class Site
    class Seiga < Base
      require 'rexml/document'
      include Connectable::Seiga

      attr_reader :member_id

      def initialize member_id, options = {}
        @member_id = member_id
        super
      end

      private

      def lazy_load
        author_xml = get URI("http://seiga.nicovideo.jp/api/user/info?id=#{@member_id}")
        author_doc = REXML::Document.new author_xml.body

        update_without_overwrite author: author_doc.text('response/user/nickname')

        xml = get URI("http://seiga.nicovideo.jp/api/user/data?id=#{@member_id}")
        doc = REXML::Document.new xml.body

        @books = doc.get_elements('/response/image_list/image').map{ |image|
          id = image.text('id')
          title = image.text('title')
          Book::Seiga.new id, bookinfo.merge(title: title, episode: nil).merge(@options)
        }.reverse

        true
      end
    end
  end
end
