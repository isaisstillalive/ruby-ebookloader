# coding: utf-8

module EBookloader
  class Book
    # 複数ページの電子書籍ファイルを表すモジュール
    # @!attribute [r] pages
    #   @return [Array<Page>] ページ情報
    module MultiplePages
      include LazyLoadable

      attr_lazy_reader :pages

      require_relative 'multiple_pages/page'

      private

      # 保存の実処理
      # @param save_path [Pathname] 保存先
      # @param options [#to_hash] 保存オプション
      # @option options [Boolean] :zip trueならばzip圧縮する
      # @return [Boolean] 成功したか
      # @see Book::Base#save
      def save_core save_path, options = {}
        save_path.mkpath unless save_path.exist?

        offset = self.options[:offset] || 0
        pages.each do |page|
          page.save save_path, offset
        end

        zip(save_path) if options[:zip]

        true
      end

      # zip圧縮する
      # @param dir_path [Pathname] 圧縮元フォルダ
      def zip dir_path
        require 'zip'
        zip_path = dir_path.parent + ("#{dir_path.basename}.zip")

        Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
          dir_path.each_entry do |filename|
            next if filename.directory?
            zipfile.add("#{dir_path.basename}/#{filename}".encode(Encoding::Shift_JIS), dir_path + filename)
          end
        end

        dir_path.rmtree
      end
    end
  end
end
