# coding: utf-8

module EBookloader
  class Book
    class Pixiv < Base
      include Connectable::Pixiv

      attr_reader :illust_id
      attr_lazy_reader :page

      def initialize illust_id, options = {}
        @illust_id = illust_id
        super
      end

      private

      def lazy_load
        csv = get_illust_csv @illust_id

        update_without_overwrite title: csv[3], author: csv[5]
        @extension = csv[2]

        @page = URI('http://i2.pixiv.net/img%5$02d/img/%25$s/%1$d.%3$s' % csv)

        true
      end

      def save_core save_path
        save_path = save_path.parent + "#{save_path.basename}.#{@extension}"
        save_path.parent.mkpath unless save_path.parent.exist?

        write save_path, page
      end

      require_relative 'pixiv/manga'
    end
  end
end
