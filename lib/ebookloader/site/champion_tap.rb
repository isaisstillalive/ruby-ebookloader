# coding: utf-8

module EBookloader
  module Site
    class ChampionTap < Base
      def initialize identifier, options = {}
        super "http://tap.akitashoten.co.jp/comics/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri

        update_without_overwrite source.body.match(%r{<header><h1><strong>(?<title>.*?)</strong> ／ (?<author>.*?)</h1></header>}).extend(Extensions::MatchData)

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{<li><a href="(?<uri>[^"]*)" class="openViewer".*?<figcaption><strong>(?<episode_num>.*?)（[^）]*?）</strong>(?<episode>.*?)</figcaption>}m).reverse_each.map do |sc|
          uri = @uri + sc[:uri]

          episode = '%s %s' % [Book::Base.get_episode_number(sc[:episode_num]), sc[:episode]]
          Book::AkitashotenReadingCommunicator.new(uri, bookinfo.merge(episode: episode))
        end

        true
      end
    end
  end
end
