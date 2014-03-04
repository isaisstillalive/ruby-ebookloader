# coding: utf-8

module EBookloader
  class Book
    class FlipperU < Base
      include Book::MultiplePages
      require 'rexml/document'
      require_relative 'flipper_u/page'

      private

      def lazy_load
        configue_uri = @uri + './book.xml'
        xml = get configue_uri
        doc = REXML::Document.new xml.body

        bookInformation = doc.elements['/setting/bookInformation']
        sliceViewer = doc.elements['/setting/renderer/SliceViewer']

        merge title: bookInformation.text('bookTitle')

        scale = bookInformation.text('maxMagnification').to_i
        options_base = {
          extension: sliceViewer.text('fileExtension').to_sym,
          prefix: sliceViewer.text('pathPrefix'),
          scale: scale,
          width: slice_count(bookInformation, 'Width', scale),
          height: slice_count(bookInformation, 'Height', scale),
        }

        datas = bookInformation.text('data').split(',')
        labels = bookInformation.text('label').split(',')
        @pages = datas.zip(labels).map do |page, name|
          options = options_base.dup
          options[:page] = page.to_i;
          options[:name] = name unless page == name
          Page.new @uri + "./page#{page}/page.xml", options
        end

        true
      end

      def slice_count elements, key, scale
        pageSize = elements.text("page#{key}").to_i
        sliceSize = elements.text("slice#{key}").to_i
        ((pageSize * scale).to_f / sliceSize).ceil
      end
    end
  end
end
