# coding: utf-8

module EBookloader
  class Book
    class Pixiv < Book
      attr_reader :illust_id
      attr_lazy_reader :page

      def initialize illust_id, options = {}
        @illust_id = illust_id
        super
      end

      private

      def lazy_load
        csv = get_illust_csv

        self.merge! title: csv[3], author: csv[5]
        @extension = csv[2]

        @page = URI('http://i2.pixiv.net/img%5$02d/img/%25$s/%1$d.%3$s' % csv)

        true
      end

      def save_core save_path
        save_path = save_path.parent + "#{save_path.basename}.#{@extension}"
        save_path.parent.mkpath unless save_path.parent.exist?

        headers = {}
        headers['Referer'] = 'http://iphone.pxv.jp/'
        headers['Cookie'] = "PHPSESSID=#{session}"

        write save_path, page, headers
      end

      def get_illust_csv
        require 'csv'
        csv = pixiv_request :get, URI("http://spapi.pixiv.net/iphone/illust.php?illust_id=#{@illust_id}&PHPSESSID=#{session}")
        csv.body.force_encoding Encoding::UTF_8
        csv.body.parse_csv
      end

      def pixiv_request method, uri, options = {}
        headers = options[:headers] || {}
        headers['Referer'] = 'http://iphone.pxv.jp/'
        headers['Cookie'] = "PHPSESSID=#{session}"

        run_request method, uri, options
      end

      def session
        login if @session.nil?
        @session
      end

      def login
        return if @options[:pixiv_id].nil? || @options[:password].nil?

        header = post URI('https://www.secure.pixiv.net/login.php'), "mode=login&pixiv_id=#{@options[:pixiv_id]}&pass=#{@options[:password]}"
        set_cookie = header['set-cookie']
        @session = set_cookie.match(/PHPSESSID=(\d*_[0-9a-f]{32})/)[1]
      end

      require_relative 'pixiv/manga'
    end
  end
end
