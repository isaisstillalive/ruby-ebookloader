# coding: utf-8

module EBookloader
  class Book
    module MultiplePages
      include LazyLoadable
      attr_lazy_reader :pages

      require_relative 'multiple_pages/page'

      private

      def save_core save_path, options = {}
        save_path.mkpath unless save_path.exist?

        offset = self.options[:offset] || 0
        pages.each do |page|
          page.save save_path, offset
        end

        zip(save_path) if options[:zip]

        true
      end

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
