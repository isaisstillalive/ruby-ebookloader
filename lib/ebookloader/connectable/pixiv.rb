# coding: utf-8

module EBookloader
  module Connectable
    module Pixiv
      include Connectable

      private

      def run_request method, uri, body = nil, headers = {}
        uri.query ||= ''
        uri.query += "&PHPSESSID=#{session}"

        headers ||= {}
        headers['Referer'] = 'http://iphone.pxv.jp/'
        headers['Cookie'] = "PHPSESSID=#{session}"

        super method, uri, body, headers
      end

      def get_csv uri
        require 'csv'
        csv = get uri
        csv.body.force_encoding Encoding::UTF_8
        CSV.parse csv.body
      end

      def get_illust_csv illust_id
        get_csv(URI("http://spapi.pixiv.net/iphone/illust.php?illust_id=#{illust_id}"))[0]
      end

      def session
        login if @session.nil?
        @session
      end

      def login
        return if @options[:pixiv_id].nil? || @options[:password].nil?

        @session = 'dummy'
        header = post URI('https://www.secure.pixiv.net/login.php'), "mode=login&pixiv_id=#{@options[:pixiv_id]}&pass=#{@options[:password]}"
        set_cookie = header['set-cookie']
        @session = set_cookie.match(/PHPSESSID=(\d*_[0-9a-f]{32})/)[1]
      end
    end
  end
end
