# coding: utf-8

module EBookloader
  class Book
    class FlipperU
      class Page < EBookloader::Book::MultiplePages::Page
        def save page, dir
          require 'rubygems'
          require 'rmagick'

          baseUri = @uri + "./x#{@options[:scale]}/"

          index = 1
          imagelist = Magick::ImageList.new
          @options[:height].times do
            h_imagelist = Magick::ImageList.new
            @options[:width].times do
              uri = baseUri + "./#{index}.#{@options[:extension]}"
              h_imagelist.from_blob get(uri, @options).body
              index += 1
            end
            imagelist << h_imagelist.append(false)
          end

          file = dir + filename(page)
          image = imagelist.append(true)
          image.write file
        end
      end
    end
  end
end
