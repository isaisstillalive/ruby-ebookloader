# coding: utf-8

module EBookloader
  class Book < Class.new
    Base = self.superclass

    class Base
      include Connectable
      include LazyLoadable
      include BookInfo

      attr_reader :uri
      attr_accessor :options
      attr_lazy_accessor :title, :author, :episode

      def initialize uri, options = {}
        @uri = URI(uri)
        @options = self.update!(options)
      end

      def save dir
        dir_path = Pathname(dir)
        dir_path.mkdir unless dir_path.exist?

        save_core dir_path
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

      def save_core dir_path
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

    require_relative 'book/multiple_pages'

    require_relative 'book/direct'
    require_relative 'book/acti_book'
    require_relative 'book/akitashoten_reading_communicator'
    require_relative 'book/aoharu'
    require_relative 'book/ura_sunday'
    require_relative 'book/togetter'
    require_relative 'book/flipper_u'
  end
end
