module EBookloader
    class Site < Class.new
        Base = self.superclass

        class Base
            include Connectable
            include LazyLoadable

            attr_reader :uri
            attr_lazy_accessor :name, :books

            def initialize uri, name = nil
                @uri = URI(uri)
                @name = name
            end

            def books
                to_enum :books_core
            end

            def books_core &block
                load
                @books.each &block
            end
        end
    end
end