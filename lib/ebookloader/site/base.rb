# coding: utf-8

module EBookloader
  module Site
    # 電子書籍サイトの基本クラス
    # @abstract
    # @!attribute [r] uri
    #   @return [URI] URI
    # @!attribute [r] options
    #   @return [Hash] オプション
    # @!attribute [r] books
    #   @return [Array<Book::Base>] 書籍
    class Base
      include Connectable
      include LazyLoadable
      include BookInfo

      attr_reader :uri, :options
      attr_lazy_accessor :books

      # 初期化
      # @param uri_str [URI, String] URI、またはURI文字列
      # @param options [#to_hash] オプション
      # @option options [String] :title 題名
      # @option options [String] :author 作者名
      # @raise [URI::InvalidURIError] URI文字列がパースできなかった場合に発生します
      def initialize uri, options = {}
        @uri = URI(uri)
        @options = update(options)
      end

      # 比較する
      def == other
        return false unless self.class == other.class
        return false unless self.uri == other.uri
        return false unless self.options == other.options

        true
      end
    end
  end
end
