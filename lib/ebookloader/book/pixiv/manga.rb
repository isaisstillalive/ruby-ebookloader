# coding: utf-8

module EBookloader
  class Book
    class Pixiv
      class Manga < Pixiv
        include Book::MultiplePages

        private

        def lazy_load
          csv = get_illust_csv

          self.merge! title: csv[3], author: csv[5]
          @extension = csv[2]

          page_count = csv[19].to_i
          @pages = (1..page_count).map do |page|
            Page.new "http://i2.pixiv.net/img%5$02d/img/%25$s/%1$d_big_p#{page-1}.%3$s" % csv, page: page, headers: { 'Referer' => 'http://www.pixiv.net/' }
          end

          true
        end
      end
    end
  end
end
