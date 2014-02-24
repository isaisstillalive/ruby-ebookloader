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
          v_files = (1..@options[:height]).map do |y|
            (dir + "#{page}_0_#{y}.tmp").tap do |file|
              h_files = (1..@options[:width]).map do |x|
                (dir + "#{page}_#{x}_#{y}.tmp").tap do |file|
                  uri = baseUri + "./#{index}.#{@options[:extension]}"
                  write file, uri, @options
                  index += 1
                end
              end

              join file, false, *h_files
            end
          end

          file = dir + filename(page)
          join file, true, *v_files
        end

        def join output_path, is_vertically, *join_paths
            imagelist = Magick::ImageList.new(*join_paths).append is_vertically
            imagelist.write output_path

            join_paths.each{ |file| file.delete }
        end
      end
    end
  end
end
