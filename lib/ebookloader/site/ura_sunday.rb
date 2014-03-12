# coding: utf-8

module EBookloader
  class Site
    class UraSunday < Base
      def initialize identifier, options = {}
        super "http://urasunday.com/#{identifier}/index.html", options
      end

      private
      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{<div class="detailComicDetailComicTitle">\s*<h2>(?<title>[^<]*)</h2>\s*</div>\s*<div class="detailComicDetailComicMangaka">\s*<h3>(?<author>[^<]*)</h3>\s*</div>}m).extend(Extensions::MatchData)

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{<ul>\s*<li class="detailComicDetailNLT02NumberBoxH">\s*<p>(?<episode>[^<]*?)</p>\s*</li>\s*<li class="detailComicDetailNLT02NumberBoxB">\s*<a href="(?<uri>.*?)" class="cNum01"><span class="swapImg">1</span></a>\s*</li>.*?</ul>}m).map do |sc|
          uri = @uri + sc[:uri]
          Book::UraSunday.new(uri, bookinfo.merge(episode: sc[:episode]))
        end

        true
      end
    end
  end
end
