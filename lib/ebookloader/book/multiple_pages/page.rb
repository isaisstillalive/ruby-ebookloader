# coding: utf-8

module EBookloader
  class Book
    module MultiplePages
      class Page
        include Connectable
        attr_reader :uri

        def initialize uri, options = {}
          @uri = URI(uri)
          @options = options
        end

        def name
          @options[:name]
        end

        def extension
          if @options[:extension]
            @options[:extension]
          else
            extension = Pathname(uri.path).extname
            if extension.empty?
              :jpg
            else
              extension[1..-1].to_sym
            end
          end
        end

        def filename page
          format = if name
            '%1$03d_%3$s.%2$s'
          else
            '%1$03d.%2$s'
          end
          format % [page, extension, name]
        end

        def save page, dir
          file = dir + filename(page)
          write file, @uri, @options
        end

        def == other
          return false unless self.uri == other.uri
          return false unless self.name == other.name
          return false unless self.extension == other.extension

          true
        end
      end
    end
  end
end
