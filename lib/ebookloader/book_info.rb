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

    # 書籍情報を上書き更新する
    # @param [#to_hash] options 書籍情報
    # @option options [String] :title 題名
    # @option options [String] :author 作者名
    # @return [Hash] 処理されなかった書籍情報
    def update options
      update_core options, true
    end

    private

    # 書籍情報を上書きしないで更新する
    # @param [#to_hash] options 書籍情報
    # @option options [String] :title 題名
    # @option options [String] :author 作者名
    # @return [Hash] 処理されなかった書籍情報
    def update_without_overwrite options
      update_core options, false
    end

    # 書籍情報をまとめて更新する実処理
    # @param [#to_hash] options 書籍情報
    # @option options [String] :title 題名
    # @option options [String] :author 作者名
    # @param [Boolean] overwrite 上書きするかどうか
    # @return [Hash] 処理されなかった書籍情報
    # @see EBookloader::BookInfo#update
    # @see EBookloader::BookInfo#update_without_overwrite
    def update_core options, overwrite = true
      return {} if options.nil?
      options = Hash[options]

      if options.include? :title
        @title = options[:title] if overwrite || !@title
        options.delete :title
      end
      if options.include? :author
        @author = options[:author] if overwrite || !@author
        options.delete :author
      end
      @bookinfo = {title: @title, author: @author}
      options
    end
  end
end
