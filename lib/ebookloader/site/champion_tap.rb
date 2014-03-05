module EBookloader
  class Site
    class ChampionTap < Base
      def initialize identifier, options = {}
        super "http://tap.akitashoten.co.jp/comics/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        update_without_overwrite source.body.match(%r{<header><h1><strong>(?<title>.*?)</strong> ／ (?<author>.*?)</h1></header>}).extend(Extensions::MatchData)

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{<li><a href="(?<uri>[^"]*)" class="openViewer".*?<figcaption><strong>(?<episode_num>.*?)（[^）]*?）</strong>(?<episode>.*?)</figcaption>}m).reverse_each.map do |sc|
          uri = @uri + sc[:uri]

          episode = '%s %s' % [Site.get_episode_number(sc[:episode_num]), sc[:episode]]
          Book::AkitashotenReadingCommunicator.new(uri, bookinfo.merge(episode: episode))
        end

        true
      end
    end
  end
end
