# coding: utf-8

module EBookloader
  module Site
    class MangaLifeWin < Base
      def initialize identifier, options = {}
        super "http://mangalifewin.takeshobo.co.jp/#{identifier}/", options
      end

      private
      def lazy_load
        source = ''
        page = 1

        loop.with_index 1 do |_, page|
          page_source = get(@uri + "?page=#{page}")
          source << page_source.body

          next if page_source.body.match(%r{<a href="(.*?)" title="next page">})
          break
        end

        update_without_overwrite source.match(%r{<h3 class="articleTitle">(?<title>.*?)</h3>\s*<h4 class="articleAuthor">(?<author>.*?)</h4>}).extend(Extensions::MatchData)

        source.extend EBookloader::Extensions::String
        @books = source.global_match(%r{<li class="bookli">.*?<img src="(?<uri>[^"]*)"  />\s*<h5>((#{title}　)?(?<episode_num>[^<]*?)(　| )(?<episode>[^<]*?)|(?<title>[^<]*?)【(?<episode_num>[^<]*?)】)</h5>.*?</li>}m).reverse_each.map do |sc|
          uri = URI(sc[:uri]) + './book/_SWF_Window.html'
          episode = ('%s %s' % [Book::Base.get_episode_number(sc[:episode_num]), sc[:episode]]).strip
          Book::ActiBook.new(uri, bookinfo.merge(episode: episode))
        end

        true
      end
    end
  end
end
