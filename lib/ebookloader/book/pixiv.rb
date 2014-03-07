# coding: utf-8

module EBookloader
  class Book
    class Pixiv < Base
      include Connectable::Pixiv

      attr_reader :illust_id
      attr_lazy_reader :page, :extension

      def initialize illust_id, options = {}
        @illust_id = illust_id
        super
      end

      private

      def lazy_load
        csv = update_from_illust_csv

        @extension = csv[2]
        @page = URI('http://i2.pixiv.net/img%5$02d/img/%25$s/%1$d.%3$s' % csv)

        true
      end

      def update_from_illust_csv
        csv = get_illust_csv @illust_id

        update_without_overwrite title: csv[3], author: csv[5]

        csv
      end

      def save_core save_path, options = {}
        save_path = save_path.sub_ext('.' + extension) if extension
        save_path.parent.mkpath unless save_path.parent.exist?

        write save_path, page
      end

      require_relative 'pixiv/manga'
    end
  end
end
