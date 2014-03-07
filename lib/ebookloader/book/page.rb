# coding: utf-8

module EBookloader
  class Book
    class Page
      include Connectable
      attr_reader :uri, :options

      def initialize uri, options = {}
        @uri = URI(uri)
        @options = options.dup

        unless @options[:extension]
          extension = Pathname(@uri.path).extname
          @options[:extension] = if extension.empty?
            :jpg
          else
            extension[1..-1].to_sym
          end
        end

        @options.freeze
      end

      def name
        @options[:name]
      end

      def page
        @options[:page]
      end

      def extension
        @options[:extension]
      end

      def filename offset = 0
        if self.page
          page = self.page + offset
          if name
            format = '%1$03d_%3$s.%2$s'
          else
            format = '%1$03d.%2$s'
          end
        else
          format = '%3$s.%2$s'
        end
        format % [page, extension, name]
      end

      def save dir, offset = 0
        file = Pathname(dir) + filename(offset)
        write file, @uri, @options[:headers]
        true
      end

      def == other
        return false unless self.class == other.class
        return false unless self.uri == other.uri
        return false unless self.options == other.options

        true
      end
    end
  end
end
