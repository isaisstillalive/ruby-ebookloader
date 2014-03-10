# coding: utf-8

module EBookloader
  module Connectable
    module Seiga
      require 'rexml/document'
      include Connectable

      private

      def get_author member_id
        xml = get URI("http://seiga.nicovideo.jp/api/user/info?id=#{member_id}")
        doc = REXML::Document.new xml.body
        doc.text('response/user/nickname')
      end

      def run_request method, uri, body = nil, headers = {}
        headers ||= {}
        headers['Cookie'] = "user_session=#{session}"

        result = super method, uri, body, headers
        result.body.force_encoding Encoding::UTF_8
        result
      end

      def session
        login if @session.nil?
        @session
      end

      def login
        return if @options[:login_id].nil? || @options[:password].nil?

        @session = 'dummy'
        header = post URI('https://secure.nicovideo.jp/secure/login?site=seiga'), "mail=#{@options[:login_id]}&password=#{@options[:password]}"

        set_cookie = header['set-cookie']
        @session = set_cookie.match(/user_session=(user_session_\d*_[0-9a-f]{64})/)[1]
      end
    end
  end
end
