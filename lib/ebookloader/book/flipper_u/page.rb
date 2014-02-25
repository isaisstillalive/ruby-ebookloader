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
          v_files = sliced_files(@options[:height], dir, "#{page}_0_%d.tmp")
          v_files.each.with_index 1 do |file, y|
            h_files = sliced_files(@options[:width], dir, "#{page}_%d_#{y}.tmp")
            h_files.each.with_index 1 do |file, x|
              uri = baseUri + "./#{index}.#{@options[:extension]}"
              write file, uri, @options
              index += 1
            end

            join file, false, *h_files
          end

          file = dir + filename(page)
          join file, true, *v_files
        end

        def join output_path, is_vertically, *join_paths
            imagelist = Magick::ImageList.new(*join_paths).append is_vertically
            imagelist.write output_path

            join_paths.each{ |file| file.delete }
        end

        private
        def sliced_files count, dir, filename_format
          (1..count).map{ |i| dir + filename_format % i }
        end
      end
    end
  end
end
