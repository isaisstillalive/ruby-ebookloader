# coding: utf-8

module EBookloader
  module Site
    class TonarinoYJ < Base
      def initialize identifier, options = {}
        super "http://tonarinoyj.jp/manga/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        match = source.body.match(%r{<h1><img src="[^"]*?" alt="(?<title>.*?)" /></h1>\s*?<h2>(?<author>.*?)</h2>}m)
        author = BookInfo.get_author(match[:author])
        update_without_overwrite title: match[:title], author: author

        source.body.match %r{<div class="backnumber"(?<list>.*?)<!-- backnumber - 番外編 -->(?<extra>.*?)<!-- //.backnumber -->}m do |m|
          list = (m[:extra] + m[:list])
          list.extend EBookloader::Extensions::String
          @books = list.global_match(%r{<li>\s*(?:<a\s*href="(?<uri>.*?)".*?>\s*(?<episode>.*?)\s*</a>|<div.*?>\s*<strong>(?<episode>.*?)</strong>.*?<a href="(?<uri>[^"]*)">\s*縦読み\s*</a>\s*</div>)\s*</li>}m).reverse_each.map do |sc|
            uri = @uri + sc[:uri]
            Book::Aoharu.new(uri, bookinfo.merge(episode: sc[:episode], img_server: 'http://img.tonarinoyj.jp/'))
          end
        end

        true
      end
    end
  end
end
