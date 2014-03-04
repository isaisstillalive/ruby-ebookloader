# coding: utf-8

module EBookloader
  class Book
    class Base
      include Connectable
      include LazyLoadable
      include BookInfo

      attr_reader :uri
      attr_accessor :options
      attr_lazy_accessor :title, :author, :episode

      def initialize uri, options = {}
        @uri = URI(uri)
        @options = update(options)
      end

      def save dir, options = {}
        dir_path = Pathname(dir) + name
        save_core dir_path, options
      end

      def == other
        return false unless self.class == other.class
        return false unless self.uri == other.uri

        true
      end

      def name
        if @episode
          "#{super} #{@episode}"
        else
          super
        end
      end

      private

      def save_core save_path, options = {}
        true
      end

      def update_core options, merge = false
        super.tap do |options|
          if options.include? :episode
            @episode = options[:episode] unless merge && @episode
            options.delete :episode
          end
        end
      end
    end
  end
end
