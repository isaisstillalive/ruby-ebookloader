# coding: utf-8

module EBookloader
  module Book
    # 電子書籍の基本クラス
    # @abstract
    # @!attribute [r] uri
    #   @return [URI] URI
    # @!attribute [r] options
    #   @return [Hash] オプション
    # @!attribute [r] page
    #   @return [Page] ページ
    # @!attribute [rw] episode
    #   @return [String] エピソード名
    class Base
      include Connectable
      include LazyLoadable
      include BookInfo

      attr_reader :uri, :options
      attr_lazy_accessor :episode
      attr_lazy_reader :page

      # @!attribute [r] name
      # @return [String] ファイル名
      # @see EBookloader::BookInfo#name
      def name
        if self.episode
          episode = BookInfo.escape_name self.episode.strip
          "#{super} #{episode}"
        else
          super
        end
      end

      # 初期化
      # @param uri_str [URI, String] URI、またはURI文字列
      # @param options [#to_hash] 初期化オプション
      # @option options [String] :title 題名
      # @option options [String] :author 作者名
      # @option options [String] :episode エピソード名
      # @option options [Integer &gt; 0] :slice ページの先頭を除外する（2ならば先頭の2ページを除外）
      # @option options [Integer &lt; 0] :slice ページの末尾を除外する（-1ならば末尾の1ページを除外）
      # @option options [Range] :slice ページの前後を除外する（1..-3ならば先頭の1ページと末尾の3ページを除外）
      # @note :sliceオプションは、負数の扱いがArray#slice(Range)とは異なります
      # @raise [URI::InvalidURIError] URI文字列がパースできなかった場合に発生します
      def initialize uri_str, options = {}
        @uri = URI(uri_str)
        @options = update(options)
      end

      # 保存する
      # @param dir [Pathname, String] 保存先ディレクトリ
      # @param options [#to_hash] 保存オプション
      # @return [Boolean] 成功したか
      # @see Book::Base#save_core
      def save dir, options = {}
        save_core Pathname(dir), Hash[options]
      end

      # 比較する
      def == other
        return false unless self.class == other.class
        return false unless self.uri == other.uri
        return false unless self.options == other.options

        true
      end

      def << other
        self.extend MultiplePages
        self << other
      end

      def + other
        self.dup << other
      end

      def dup
        super.tap do |book|
          book.page = book.page.dup if book.page
        end
      end

      protected

      attr_writer :page

      private

      # 保存の実処理
      # @param dir [Pathname] 保存先ディレクトリ
      # @param options [Hash] 保存オプション
      # @return [Boolean] 成功したか
      # @abstract サブクラスで上書きする
      # @see Book::Base#save
      def save_core dir, options = {}
        dir.mkpath unless dir.exist?
        page.save dir
      end

      # 書籍情報をまとめて更新する実処理
      # @param options [#to_hash] 書籍情報
      # @option options [String] :title 題名
      # @option options [String] :author 作者名
      # @option options [String] :episode エピソード名
      # @param overwrite [Boolean] 上書きするかどうか
      # @return [Hash] 処理されなかった書籍情報
      # @see EBookloader::BookInfo#update_core
      def update_core options, overwrite = true
        super.tap do |options|
          if options.include? :episode
            self.episode = options[:episode] if overwrite || !self.episode
            options.delete :episode
          end
        end
      end

      def generate_pages enum
        enum.each do |v|
        end
      end

      class << self
        def get_episode_number episode_number
          return '%02d' % episode_number if episode_number.match /^\d*$/
          return '%05.2f' % episode_number if episode_number.match /^\d\.\d*$/

          match = episode_number.match /(?:第|#)(?<first>\d+)(-(?<last>\d+))?(?:話|回)?/
          return episode_number unless match

          format = match[:last] ? '%02d-%02d' : '%02d'
          format % [match[:first].to_i, match[:last].to_i]
        end
      end
    end
  end
end
