# coding: utf-8

module EBookloader
  module Site
    class Mavo < Base
      def initialize identifier, options = {}
        super "http://mavo.takekuma.jp/title.php?title=#{identifier}", options
      end

      private
      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{<h2><img[^>]*alt="(?<title>.*?)" /></h2>.*?<p class='author'>(著者：)?(?<author>.*?)</p>}m).extend(Extensions::MatchData)

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{<dt>(?<episode>.*?)<br/><span class='detail'>(?<detail>.*?)</span></dt>(<dd>)?<dd>(<a href='pcviewer\.php\?id=(?<id>[^']*?)'  id='(?<pc>pc)'>見開き\(PC\)</a>)?(<a href='ipviewer\.php\?id=(?<id>[^']*?)' id='(?<ip1>ip1)'>見開き\(iPhone/iPad\)</a>)?(<a href='ipviewer2\.php\?id=(?<id>[^']*?)' id='(?<ip2>ip2)'>スクロール</a>)?</dd>}m).reverse_each.map do |sc|
          Book::Mavo.new(sc[:id], bookinfo.merge(episode: sc[:episode], mode: (sc[:ip2] || sc[:ip1] || sc[:pc])))
        end

        true
      end
    end
  end
end
