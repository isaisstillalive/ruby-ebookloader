# coding: utf-8

module EBookloader
  # 電子書籍ファイル
  # @!parse class Book < Book::Base; end
  # @!parse class Book::Base; end
  class Book < Class.new
    Base = self.superclass

    private

    # 遅延読み込みを行う
    # @return [Boolean] 成功したか
    def lazy_load
      path = Pathname(@uri.path)
      name = path.basename('.*').to_s
      extension = path.extname[1..-1].to_sym

      update_without_overwrite title: name

      @page = Page.new @uri, options.merge(name: name, extension: extension)

      true
    end

    require_relative 'book/base'
    require_relative 'book/page'
    require_relative 'book/multiple_pages'

    require_relative 'book/acti_book'
    require_relative 'book/akitashoten_reading_communicator'
    require_relative 'book/aoharu'
    require_relative 'book/ura_sunday'
    require_relative 'book/togetter'
    require_relative 'book/flipper_u'
    require_relative 'book/easy_e_paper_viewer'
    require_relative 'book/pixiv'
  end
end
