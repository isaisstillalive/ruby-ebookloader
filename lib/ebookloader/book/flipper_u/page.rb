# coding: utf-8

module EBookloader
  module Book
    class FlipperU
      class Page < EBookloader::Book::Page
        def save dir, offset = 0
          require 'rubygems'
          require 'rmagick'

          baseUri = self.uri + "./x#{@options[:scale]}/"

          index = 1
          imagelist = Magick::ImageList.new
          @options[:height].times do
            h_imagelist = Magick::ImageList.new
            @options[:width].times do
              uri = baseUri + "./#{index}.#{self.extension}"
              h_imagelist.from_blob get(uri).body
              index += 1
            end
            imagelist << h_imagelist.append(false)
          end

          file = dir + filename(offset + page)
          image = imagelist.append(true)
          image.write file
        end
      end
    end
  end
end
