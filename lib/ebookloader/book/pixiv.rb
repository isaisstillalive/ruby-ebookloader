# coding: utf-8

module EBookloader
  class Book
    class Pixiv < Base
      include Connectable::Pixiv

      attr_reader :illust_id

      def initialize illust_id, options = {}
        @illust_id = illust_id
        super
      end

      private

      def lazy_load
        csv = update_from_illust_csv

        extension = csv[2]
        uri = URI('http://i2.pixiv.net/img%5$02d/img/%25$s/%1$d.%3$s' % csv)

        @page = Page.new uri, options.merge(name: title, extension: extension)
        @page.extend Connectable::Pixiv

        true
      end

      def update_from_illust_csv
        csv = get_illust_csv @illust_id

        update_without_overwrite title: csv[3], author: csv[5]

        csv
      end

      require_relative 'pixiv/manga'
    end
  end
end
