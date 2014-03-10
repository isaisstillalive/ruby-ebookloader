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
        update_without_overwrite author: get_author(@member_id)

        xml = get URI("http://seiga.nicovideo.jp/api/user/data?id=#{@member_id}")
        doc = REXML::Document.new xml.body

        @books = doc.get_elements('/response/image_list/image').map{ |image|
          id = image.text('id')
          title = image.text('title')
          Book::Seiga.new id, bookinfo.merge(title: title, episode: nil).merge(@options)
        }.reverse

        true
      end

      require_relative 'seiga/manga'
    end
  end
end
