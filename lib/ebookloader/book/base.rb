# coding: utf-8

module EBookloader
  class Book
    # @abstract
    # @!attribute [r] uri
    #   @return [URI] URI
    # @!attribute [rw] options
    #   @return [Hash] オプション
    # @!attribute [rw] episode
    #   @return [String] エピソード名
    class Base
      include Connectable
      include LazyLoadable
      include BookInfo

      attr_reader :uri
      attr_accessor :options
      attr_lazy_accessor :title, :author, :episode

      # @param [URI, String] uri URI
      # @param [#to_hash] options オプション
      # @option options [String] :title 題名
      # @option options [String] :author 作者名
      # @option options [String] :episode エピソード名
      def initialize uri, options = {}
        @uri = URI(uri)
        @options = update(options)
      end

      # @param [Pathname,String] dir 保存先
      # @param [#to_hash] options オプション
      # @return [Boolean] 成功したか
      def save dir, options = {}
        dir_path = Pathname(dir) + name
        save_core dir_path, options
      end

      def == other
        return false unless self.class == other.class
        return false unless self.uri == other.uri

        true
      end

      # @!attribute [r] name
      # @return [String] ファイル名
      # @see EBookloader::BookInfo#name
      def name
        if @episode
          "#{super} #{@episode}"
        else
          super
        end
      end

      private

      # 保存の実処理
      # @param [Pathname] save_path 保存先
      # @param [#to_hash] options Book::Base#save に渡されたオプション
      # @return [Boolean] 成功したか
      # @abstract サブクラスで上書きする
      # @see Book::Base#save
      def save_core save_path, options = {}
        true
      end

      # 属性をまとめて更新する実処理
      # @param [#to_hash] options 新しい値
      # @option options [String] :title 題名
      # @option options [String] :author 作者名
      # @option options [String] :episode エピソード名
      # @return [Hash] 処理されなかった新しい値
      # @see EBookloader::BookInfo#update_core
      def update_core options, merge = false
        super.tap do |options|
          if options.include? :episode
            @episode = options[:episode] unless merge && @episode
            options.delete :episode
          end
        end
      end
    end
  end
end
