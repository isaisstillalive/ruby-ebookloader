# coding: utf-8

module EBookloader
  class Book
    module MultiplePages
      include LazyLoadable
      attr_lazy_reader :pages

      require_relative 'multiple_pages/page'

      private

      def save_core save_path
        save_path.mkpath unless save_path.exist?

        offset = options[:offset] || 1
        pages.each.with_index offset do |page, index|
          page.save index, save_path
        end

        true
      end
    end
  end
end
