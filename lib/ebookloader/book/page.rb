# coding: utf-8

module EBookloader
  module Book
    class Page
      include Connectable
      attr_reader :options

      # @param uri [String, URI] URI文字列
      # @param options [#to_hash] オプション
      def initialize *args, &block
        if block_given?
          raise ArgumentError if args.size == 2
          uri = block
          options = args[0] || {}
        else
          raise ArgumentError if args.size == 0
          uri = args[0]
          options = args[1] || {}
        end

        @uri = uri
        @options = Hash[options]

        if @options[:extension]
          @extension = @options[:extension]
          @options.delete :extension
        end

        @options.freeze
      end

      def uri
        case @uri
          when String
            @uri = URI(@uri)
          when Proc
            @uri = URI(@uri.call)
        end
        @uri
      end

      def name
        @options[:name]
      end

      def extension
        unless instance_variable_defined? :@extension
          extension = Pathname(self.uri.path).extname
          @extension = if extension.empty?
            :jpg
          else
            extension[1..-1].to_sym
          end
        end
        @extension
      end

      def page
        @options[:page]
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
        (format % [page, extension, name]).gsub(Pathname::SEPARATOR_PAT, '_')
      end

      def save dir, offset = 0
        file = Pathname(dir) + filename(offset)
        write file, self.uri, @options[:headers]
        true
      end

      def == other
        return false unless self.class == other.class
        return false unless self.uri == other.uri
        return false unless self.extension == other.extension
        return false unless self.options == other.options

        true
      end
    end
  end
end
