# coding: utf-8

module EBookloader
  class Book < Class.new
    Base = self.superclass

    class Base
      include Connectable
      include LazyLoadable

      attr_reader :uri
      attr_accessor :options
      attr_lazy_accessor :name

      def initialize uri, options = {}
        @uri = URI(uri)
        @name = options[:name]
        options.delete :name
        @options = options
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

      private

      def save_core dir_path
        true
      end
    end

    require_relative 'book/multiple_pages'

    require_relative 'book/direct'
    require_relative 'book/acti_book'
    require_relative 'book/akitashoten_reading_communicator'
    require_relative 'book/aoharu'
    require_relative 'book/ura_sunday'
    require_relative 'book/togetter'
  end
end
