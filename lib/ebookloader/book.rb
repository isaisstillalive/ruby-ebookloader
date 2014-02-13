module EBookloader
    class Book < Class.new
        Base = self.superclass

        class Base
            include Connectable
            include LazyLoadable

            attr_reader :uri
            attr_lazy_accessor :name

            def initialize uri, name = nil
                @uri = URI(uri)
                @name = name
            end

            def save dir
                dir_path = Pathname(dir)
                dir_path.mkdir unless dir_path.exist?

                save_core dir_path
            end

            private

            def save_core dir_path
                true
            end

            def write file_path, uri
                file_path.open('wb') { |p| p.write(get(uri).body) }
            end
        end

        require_relative 'book/multiple_pages'

        require_relative 'book/direct'
        require_relative 'book/acti_book'
        require_relative 'book/akitashoten_reading_communicator'
    end
end
