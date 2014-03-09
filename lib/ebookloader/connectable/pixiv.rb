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

        result = super method, uri, body, headers
        result.body.force_encoding Encoding::UTF_8
        result
      end

      def get_csv uri
        require 'csv'

        uri = uri.dup
        query = uri.query || ''

        result = []
        loop.with_index 1 do |_, page|
          uri.query = query + "&p=#{page}"
          csv_source = get uri
          csv = CSV.parse csv_source.body
          result += csv
          break unless csv.size == 50
        end
        result
      end

      def get_single_csv uri
        require 'csv'
        csv = get uri
        CSV.parse_line csv.body
      end

      def get_illust_csv illust_id
        get_single_csv(URI("http://spapi.pixiv.net/iphone/illust.php?illust_id=#{illust_id}"))
      end

      def get_member_illist_csv member_id
        get_csv URI("http://spapi.pixiv.net/iphone/member_illust.php?id=#{member_id}")
      end

      def get_member member_id
        get URI("http://spapi.pixiv.net/iphone/profile.php?id=#{member_id}")
      end

      def session
        login if @session.nil?
        @session
      end

      def login
        return if @options[:login_id].nil? || @options[:password].nil?

        @session = 'dummy'
        header = post URI('https://www.secure.pixiv.net/login.php'), "mode=login&pixiv_id=#{@options[:login_id]}&pass=#{@options[:password]}"
        set_cookie = header['set-cookie']
        @session = set_cookie.match(/PHPSESSID=(\d*_[0-9a-f]{32})/)[1]
      end
    end
  end
end
