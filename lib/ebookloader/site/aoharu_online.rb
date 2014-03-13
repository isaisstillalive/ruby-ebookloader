# coding: utf-8

module EBookloader
  class Site
    class AoharuOnline < Base
      def initialize identifier, options = {}
        super "http://aoharu.jp/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{<h2 id="summary-title">\s*?<span class="ttl1">(?<title>[^<]*?)</span>\s*?<span class="ttl2">(?<author>[^<]*?)</span></h2>}m).extend(Extensions::MatchData)

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{<li class="card mod-s">.*?<a href="(?<uri>.*?)" class="card-togo">\s*<span class="title2">(?<episode_num>[^<]*?)</span>(?:\s*<span class="title">(?<episode>[^<]*?)</span>)?\s*</a>|<li>\s*<a href="(?<uri>[^"]*?)">\s*<span class="bitsy-stl">(?<episode_num>[^<]*?)</span>(?:\s*<span class="bitsy-ttl">(?<episode>[^<]*?)</span>)?\s*</a>\s*</li>}m).reverse_each.map do |sc|
          uri = @uri + sc[:uri]
          episode = ('%s %s' % [Book::Base.get_episode_number(sc[:episode_num]), sc[:episode]]).strip
          Book::Aoharu.new(uri, bookinfo.merge(episode: episode))
        end

        true
      end
    end
  end
end
