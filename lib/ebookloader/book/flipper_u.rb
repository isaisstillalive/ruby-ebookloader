# coding: utf-8

module EBookloader
  class Book
    class FlipperU < Book
      include Book::MultiplePages
      require 'rexml/document'
      require_relative 'flipper_u/page'

      private

      def lazy_load
        configue_uri = @uri + './book.xml'
        xml = get configue_uri
        doc = REXML::Document.new xml.body

        @name ||= doc.elements['/setting/bookInformation/bookTitle'].text

        scale = doc.elements['/setting/bookInformation/maxMagnification'].text.to_i
        prefix = doc.elements['/setting/renderer/SliceViewer/pathPrefix'].text
        extension = doc.elements['/setting/renderer/SliceViewer/fileExtension'].text.to_sym

        width = slice_count(doc.elements, 'Width', scale)
        height = slice_count(doc.elements, 'Height', scale)

        page_count = doc.elements['/setting/bookInformation/total'].text.to_i
        datas = doc.elements['/setting/bookInformation/data'].text.split(',')
        labels = doc.elements['/setting/bookInformation/label'].text.split(',')
        @pages = datas.to_enum(:zip, labels){ page_count }.lazy.map do |page, name|
          options = {
            extension: extension,
            prefix: prefix,
            scale: scale,
            width: width,
            height: height,
          }
          options[:name] = name unless page == name
          Page.new(@uri + "./page#{page}/page.xml", options)
        end

        true
      end

      def slice_count elements, key, scale
        pageSize = elements["/setting/bookInformation/page#{key}"].text.to_i
        sliceSize = elements["/setting/bookInformation/slice#{key}"].text.to_i
        ((pageSize * scale).to_f / sliceSize).ceil
      end
    end
  end
end
