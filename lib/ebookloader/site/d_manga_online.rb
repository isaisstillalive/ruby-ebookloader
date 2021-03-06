# coding: utf-8

module EBookloader
  module Site
    class DMangaOnline < Base
      def initialize identifier, options = {}
        super "http://d-manga.dengeki.com/work/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{<h2 class="workTextTtl">\s*?<img[^>]*alt="(?<title>[^"]*?)">\s*?</h2>\s*?<p class="workTextAuthor">\s*?著者名： (?<author>.*?)\s*?</p>}m).extend(Extensions::MatchData)

        source.body.match %r{<ul class="workList backnumber">(?<list>.*?)</ul>(?:.*?<ul class="workList extra">(?<extra>.*?)</ul>)?}m do |match|
          extra = match[:extra] || ''
          extra.gsub! '<a ', '番外編<a '
          list = (extra + match[:list])
          list.extend EBookloader::Extensions::String
          @books = list.global_match(%r{<li>(?<extra>.*?)<a href="(?<uri>.*?)" target="_blank">(?<episode_num>[^<]*?)</a></li>}m).reverse_each.map do |sc|
            uri = @uri + sc[:uri]
            format = sc[:extra].empty? ? '%1$s' : '%2$s %1$s'
            episode = (format % [Book::Base.get_episode_number(sc[:episode_num]), sc[:extra]]).strip
            Book::ActiBook.new(uri, bookinfo.merge(episode: episode, headers: {'Referer' => uri.to_s}))
          end
        end

        true
      end
    end
  end
end
