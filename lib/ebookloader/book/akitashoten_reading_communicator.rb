# coding: utf-8

module EBookloader
  module Book
    class AkitashotenReadingCommunicator < Base
      include Book::MultiplePages

      private

      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{<h1 title="(?<title>.*?) ">.*?<span id="author" title="(?<author>.*?)">}m).extend(Extensions::MatchData)

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
