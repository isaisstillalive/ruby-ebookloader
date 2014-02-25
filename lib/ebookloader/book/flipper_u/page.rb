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
          v_files.each.with_index 1 do |v_file, y|
            h_files = sliced_files(@options[:width], dir, "#{page}_%d_#{y}.tmp")
            h_files.each.with_index 1 do |h_file, x|
              uri = baseUri + "./#{index}.#{@options[:extension]}"
              write h_file, uri, @options
              index += 1
            end

            join v_file, h_files, false
          end

          file = dir + filename(page)
          join file, v_files, true
        end

        private
        def join output_path, join_paths, is_vertically
            imagelist = Magick::ImageList.new(*join_paths).append is_vertically
            imagelist.write output_path

            join_paths.each{ |file| file.delete }
        end

        def sliced_files count, dir, filename_format
          (1..count).map{ |i| dir + filename_format % i }
        end
      end
    end
  end
end
