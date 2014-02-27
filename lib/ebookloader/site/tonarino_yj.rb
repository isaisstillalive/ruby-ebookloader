module EBookloader
  class Site
    class TonarinoYJ < Site
      def initialize identifier, options = {}
        super "http://tonarinoyj.jp/manga/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        self.merge! source.body.match(%r{<h1><img src="[^"]*?" alt="(?<title>.*?)" /></h1>\s*?<h2>(?<author>.*?)</h2>}m)

        source.body.match %r{<div class="backnumber"(.*?)<!-- backnumber - 番外編 -->(.*?)<!-- //.backnumber -->}m do |m|
          @books = lazy_collection (m[2] + m[1]), %r{<li>\s*(?:<a\s*href="(?<uri>.*?)".*?>\s*(?<episode>.*?)\s*</a>|<div.*?>\s*<strong>(?<episode>.*?)</strong>.*?<a href="(?<uri>[^"]*)">\s*縦読み\s*</a>\s*</div>)\s*</li>}m, true do |sc|
            uri = @uri + sc[:uri]
            Book::Aoharu.new(uri, self.bookinfo.merge(episode: sc[:episode]))
          end
        end

        true
      end
    end
  end
end
