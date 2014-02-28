# coding: utf-8

module EBookloader
  class Book
    class AkitashotenReadingCommunicator < Book
      include Book::MultiplePages

      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        merge source.body.match %r{<h1 title="(?<title>.*?) ">.*?<span id="author" title="(?<author>.*?)">}m

        match = source.body.match %r{ARC.Comic = (\{.*?url: '(?<image_path>[^']*)'.*?page_count: (?<page_count>\d*).*?\})}m
        image_path = match[:image_path]
        page_count = match[:page_count].to_i

        @pages = (1..page_count).map do |page|
          Page.new @uri + "#{image_path}/#{page}", page: page
        end

        true
      end
    end
  end
end
