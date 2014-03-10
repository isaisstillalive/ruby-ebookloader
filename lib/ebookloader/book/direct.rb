# coding: utf-8

module EBookloader
  class Book
    class Direct < Base
      private

      # 遅延読み込みを行う
      # @return [Boolean] 成功したか
      def lazy_load
        path = Pathname(@uri.path)
        name = path.basename('.*').to_s
        extension = path.extname[1..-1].to_sym

        update_without_overwrite title: name

        @page = Page.new @uri, options.merge(name: name, extension: extension)

        true
      end
    end
  end
end
