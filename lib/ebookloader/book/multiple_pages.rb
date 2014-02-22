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

                pages.each.with_index 1 do |page, index|
                    page = Page.new(page) unless page.is_a? Page
                    file = dir + page.filename(index)
                    write file, page.uri
                end

                true
            end
        end
    end
end
