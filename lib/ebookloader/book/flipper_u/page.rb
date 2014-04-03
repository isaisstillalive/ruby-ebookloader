# coding: utf-8

module EBookloader
  module Book
    class FlipperU
      class Page < EBookloader::Book::Page
        def save dir, offset = 0
          require 'rubygems'
          require 'rmagick'

          if @options[:scale] == 1
            uri = self.uri + "./x#{@options[:scale]}.#{self.extension}"
            file = dir + filename(offset)
            write file, uri, @options[:headers]
            return
          end

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

          file = dir + filename(offset)
          image = imagelist.append(true)
          image.write file
        end

        private

        def tilejpeg file, join_paths
          Dir.chdir dir.to_s
          file_paths = files.map(&:basename).join(' ');
          command = "C:/Users/amioka/Downloads/tilejpeg/bin/tilejpeg.exe #{@options[:width]} #{file_paths}"
          system(command)
          file = dir + filename(page)
        end
      end
    end
  end
end
