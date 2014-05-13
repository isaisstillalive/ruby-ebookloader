# coding: utf-8

module EBookloader
  module Site
    class MangaGotAChance < Base
      def initialize identifier, options = {}
        super "http://mangag.com/manga/?p=#{identifier}", options
      end

      private
      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{&nbsp;&gt;&nbsp;\s*『(?<title>.*?)』.*■(?:作者名|作家名)：(?:<a [^>]*>)?(?<author>.*?)(?:</a>)?<br />}m).extend(Extensions::MatchData)

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{(<li>(?<episode>[^<]*?)<br />\s*|<br />\s*(?<episode>[^<]*?)(更新！<br />\s*次回更新予定日：[^<]*?)?</div>\s*<div align="center" style="padding: 0px;">&nbsp;</div>\s*<div align="center" style="padding: 0px;">)<a href="javascript:void\(0\);" onclick="javascript:Fullscreen\('(?<uri>[^']*?)'}m).reverse_each.map do |sc|
          uri = @uri + sc[:uri]
          episode = sc[:episode].gsub(/^(『(?<episode>.*?)』|「(?<episode>.*?)」)$/, '\k<episode>')
          Book::ActiBook.new(uri, bookinfo.merge(episode: episode))
        end

        true
      end
    end
  end
end
