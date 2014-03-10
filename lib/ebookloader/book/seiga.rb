# coding: utf-8

module EBookloader
  module Book
    class Seiga < Base
      require 'rexml/document'
      include Connectable::Seiga

      attr_reader :illust_id

      def initialize illust_id, options = {}
        @illust_id = illust_id
        super
      end

      private

      def lazy_load
        xml = get URI("http://seiga.nicovideo.jp/api/illust/info?id=#{@illust_id}")
        doc = REXML::Document.new xml.body

        author = get_author doc.text('/response/image/user_id') unless instance_variable_defined? :@author

        update_without_overwrite author: author, title: doc.text('/response/image/title')

        redirect = head URI("http://seiga.nicovideo.jp/image/source/#{@illust_id}")
        uri = URI(redirect[:location].gsub '/o/', '/priv/')
        @page = Page.new uri, name: name

        true
      end

      require_relative 'seiga/manga'
    end
  end
end
