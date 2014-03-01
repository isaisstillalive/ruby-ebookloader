# coding: utf-8

module EBookloader
  class Book
    class Direct < Book
      private

      def lazy_load
        self.merge! title: Pathname(@uri.path).basename.to_s
      end

      def save_core save_path
        save_path.parent.mkpath unless save_path.parent.exist?
        write save_path, uri
      end
    end
  end
end
