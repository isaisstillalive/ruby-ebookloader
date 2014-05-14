# coding: utf-8

module EBookloader
  # 電子書籍
  module Book
    require_relative 'book/base'
    require_relative 'book/page'
    require_relative 'book/multiple_pages'

    require_relative 'book/direct'
    require_relative 'book/acti_book'
    require_relative 'book/akitashoten_reading_communicator'
    require_relative 'book/aoharu'
    require_relative 'book/ura_sunday'
    require_relative 'book/togetter'
    require_relative 'book/flipper_u'
    require_relative 'book/easy_e_paper_viewer'
    require_relative 'book/pixiv'
    require_relative 'book/seiga'
    require_relative 'book/mavo'
  end
end
