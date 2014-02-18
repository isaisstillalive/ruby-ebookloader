# coding: utf-8

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

            def == other
                return false unless self.class == other.class
                return false unless self.uri == other.uri

                true
            end
        end

        require_relative 'site/comic_meteor'
    end
end