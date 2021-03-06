# coding: utf-8

module EBookloader
  module Book
    class Seiga < Base
      require 'rexml/document'
      include Connectable::Seiga

      attr_reader :id

      def initialize id, options = {}
        @id = id
        super
      end

      private

      def lazy_load
        xml = get URI("http://seiga.nicovideo.jp/api/illust/info?id=#{@id}")
        doc = REXML::Document.new xml.body

        author = get_author doc.text('/response/image/user_id') unless instance_variable_defined? :@author

        update_without_overwrite author: author, title: doc.text('/response/image/title')

        @page = Page.new name: name do
          redirect = head URI("http://seiga.nicovideo.jp/image/source/#{@id}")
          URI(redirect[:location].gsub '/o/', '/priv/')
        end

        true
      end

      require_relative 'seiga/manga'
    end
  end
end
