# coding: utf-8

module EBookloader
    class Book
        module MultiplePages
            include LazyLoadable
            attr_lazy_reader :pages

            private
            def save_core dir_path
                dir = dir_path + name
                dir.mkdir unless dir.exist?

                pages.each do |pagename, uri|
                    file = dir + pagename
                    write file, uri
                end

                true
            end
        end
    end
end
