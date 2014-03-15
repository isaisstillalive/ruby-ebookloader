# coding: utf-8

module EBookloader
  module Book
    class Pixiv < Base
      include Connectable::Pixiv

      attr_reader :id

      def initialize id, options = {}
        @id = id
        super
      end

      private

      def lazy_load
        csv = update_from_illust_csv

        extension = csv[2]
        uri = URI('http://i2.pixiv.net/img%5$02d/img/%25$s/%1$d.%3$s' % csv)

        @page = Page.new uri, name: name, extension: extension, headers: { 'Referer' => 'http://www.pixiv.net/' }

        true
      end

      def update_from_illust_csv
        csv = get_illust_csv @id

        update_without_overwrite title: csv[3], author: csv[5]

        csv
      end

      require_relative 'pixiv/manga'
    end
  end
end
