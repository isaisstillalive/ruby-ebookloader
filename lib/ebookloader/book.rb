# coding: utf-8

module EBookloader
  class Book < Class.new
    Base = self.superclass

    private

    def lazy_load
      merge title: Pathname(@uri.path).basename.to_s
    end

    def save_core save_path
      save_path.parent.mkpath unless save_path.parent.exist?
      write save_path, uri
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
