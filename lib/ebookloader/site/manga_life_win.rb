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

        update_without_overwrite source.match(%r{<h3 class="articleTitle">(?<title>.*?)</h3>\s*<h4 class="articleAuthor">(?<author>.*?)(&nbsp;先生)?</h4>}).extend(Extensions::MatchData)

        source.extend EBookloader::Extensions::String
        @books = source.global_match(%r{<li class="bookli">.*?<img src="(?<uri>[^"]*)"  />\s*<h5>((#{title}　)?(?<episode_num>[^<]*?)(　| )(?<episode>[^<]*?)|(?<title>[^<]*?)【(?<episode_num>[^<]*?)】)</h5>(?<pages>.*?<td valign="top">.*?</div>)?.*?</li>}m).reverse_each.map do |sc|
          uri = URI(sc[:uri]) + './book/_SWF_Window.html'
          episode = ('%s %s' % [Book::Base.get_episode_number(sc[:episode_num]), sc[:episode]]).strip
          if sc[:pages]
            uri = URI(sc[:uri])
            EBookloader::Book::Direct::Multiple.new(sc[:uri], bookinfo.merge(episode: episode)).tap do |book|
              book.pages.clear

              pages_source = sc[:pages].to_s
              pages_source.extend EBookloader::Extensions::String
              pages_source.global_match(%r{<td valign="top"><a href="[^"]*?/(?<page_id>[^/]*?)/" title="[^"]*?">[^<]*?(「(?<page_title>[^」]*?)」)?</a></td>}).with_index 1 do |page_sc, page|
                # , name: BookInfo.escape_name(page_sc[:page_title])
                book.pages << Book::Page.new(uri+(page_sc[:page_id]+'.jpg'), page: page)
              end
            end
          else
            Book::ActiBook.new(uri, bookinfo.merge(episode: episode))
          end
        end

        true
      end
    end
  end
end
