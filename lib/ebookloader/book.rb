# coding: utf-8

module EBookloader
  # @!parse class Book < Book::Base; end
  # @!parse class Book::Base; end
  class Book < Class.new
    Base = self.superclass

    private

    # 遅延読み込みを行う
    # @return [Boolean] 成功したか
    def lazy_load
      update_without_overwrite title: Pathname(@uri.path).basename.to_s
      true
    end

    # 保存の実処理
    # @param [Pathname] save_path 保存先
    # @param [#to_hash] options Book::Base#save に渡されたオプション
    # @return [Boolean] 成功したか
    def save_core save_path, options = {}
      save_path.parent.mkpath unless save_path.parent.exist?
      write save_path, uri
      true
    end

    require_relative 'book/base'
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
