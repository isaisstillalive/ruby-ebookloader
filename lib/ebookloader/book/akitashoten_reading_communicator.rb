# coding: utf-8

module EBookloader
  module Book
    class AkitashotenReadingCommunicator < Base
      include Book::MultiplePages

      private

      def lazy_load
        source = get @uri

        bookinfo = source.body.match(%r{<h1 title="(?<epsode_num>[^"]*)">[^<]*<span id="subtitle">(?<episode>[^<]*)</span><span id="author" title="(?<author>.*?)">.*<img id="thumbnailImage" src="[^"]*" alt="(?<title>[^"]*)">}m)
        title = bookinfo[:title]
        episode_num = bookinfo[:epsode_num].gsub(/^#{title}\s/, '').strip
        episode = "#{self.class.get_episode_number(episode_num)} #{bookinfo[:episode]}"
        update_without_overwrite title: title, author: bookinfo[:author], episode: episode

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
