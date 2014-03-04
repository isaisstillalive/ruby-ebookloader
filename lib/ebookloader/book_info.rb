# coding: utf-8

module EBookloader
  # @!attribute [rw] title
  #   @return [String] 題名
  # @!attribute [rw] author
  #   @return [String] 作者名
  # @!attribute [rw] bookinfo
  #   @return [Hash] 情報
  module BookInfo
    attr_accessor :title, :author, :bookinfo

    # @!attribute [r] name
    # @return [String] ファイル名
    def name
      return title unless author

      '[%s] %s' % [author, title]
    end

    # 属性をまとめて更新する
    # @param [#to_hash] options 新しい値
    # @option options [String] :title 題名
    # @option options [String] :author 作者名
    # @return [Hash] 処理されなかった新しい値
    def update options
      update_core options, false
    end

    # 属性をまとめて更新する
    # @param [#to_hash] options 新しい値
    # @option options [String] :title 題名
    # @option options [String] :author 作者名
    # @return [Hash] 処理されなかった新しい値
    def merge options
      update_core options, true
    end

    private

    # 属性をまとめて更新する実処理
    # @param [#to_hash] options 新しい値
    # @option options [String] :title 題名
    # @option options [String] :author 作者名
    # @param [Boolean] merge マージするかどうか
    # @return [Hash] 処理されなかった新しい値
    # @see EBookloader::BookInfo#update
    # @see EBookloader::BookInfo#merge
    def update_core options, merge = false
      return {} if options.nil?
      options = Hash[options]

      if options.include? :title
        @title = options[:title] unless merge && @title
        options.delete :title
      end
      if options.include? :author
        @author = options[:author] unless merge && @author
        options.delete :author
      end
      @bookinfo = {title: @title, author: @author}
      options
    end
  end
end
