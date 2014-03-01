# coding: utf-8

module EBookloader
  class Book
    module MultiplePages
      include LazyLoadable
      attr_lazy_reader :pages

      require_relative 'multiple_pages/page'

      private

      def save_core dir_path
        dir = dir_path + name
        dir.mkdir unless dir.exist?

        offset = options[:offset] || 1
        pages.each.with_index offset do |page, index|
          page.save index, dir
        end

        true
      end
    end
  end
end
