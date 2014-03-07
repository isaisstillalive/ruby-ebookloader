# coding: utf-8

module EBookloader
  class Book
    # 複数ページの電子書籍ファイルを表すモジュール
    # @!attribute [r] pages
    #   @return [Array<Page>] ページ情報
    module MultiplePages
      include LazyLoadable

      attr_lazy_reader :pages

      def << other
        other_pages = other.pages rescue [other.page]

        other_pages.each.with_index(@pages.size+1) do |new_page, page|
          new_page = new_page.dup

          options = Hash[new_page.options]
          options[:page] = page
          new_page.instance_variable_set :@options, options

          @pages << new_page
        end

        self
      end

      private

      # 保存の実処理
      # @param dir [Pathname] 保存先ディレクトリ
      # @param options [Hash] 保存オプション
      # @option options [Boolean] :zip trueならばzip圧縮する
      # @option options [Integer] :offset (0) 保存時にページ番号をズラす値
      # @return [Boolean] 成功したか
      # @see Book::Base#save
      def save_core dir, options = {}
        save_path = dir + name
        save_path.mkpath unless save_path.exist?

        offset = options[:offset] || 0

        pages = self.pages
        if self.options[:slice]
          slice = self.options[:slice]

          case slice
          when Integer
            slice = (slice >= 0) ? slice..-1 : 0..(slice-1)
          when Range
            if slice.last < 0
              slice = slice.first..(slice.last-1)
            end
          end
          offset -= slice.first
          pages = pages[slice]
        end

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
        zip_path = dir_path.sub_ext('.zip')

        Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
          dir_path.each_entry do |filename|
            next if filename.directory?
            zipfile.add("#{dir_path.basename}/#{filename}".encode(Encoding::Shift_JIS, invalid: :replace, undef: :replace), dir_path + filename)
          end
        end

        dir_path.rmtree
      end
    end
  end
end
