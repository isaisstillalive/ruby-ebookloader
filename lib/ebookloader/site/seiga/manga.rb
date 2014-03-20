# coding: utf-8

module EBookloader
  module Site
    class Seiga
      class Manga < Base
        require 'rexml/document'
        include Connectable::Seiga

        attr_reader :manga_id

        def initialize manga_id, options = {}
          @manga_id = manga_id
          super
        end

        private

        def lazy_load
          xml = get URI("http://seiga.nicovideo.jp/api/manga/info?id=#{@manga_id}")
          doc = REXML::Document.new xml.body

          title = doc.text('response/manga/title')
          author = doc.text('response/manga/author_name')
          update_without_overwrite author: author, title: title

          source = get URI("http://seiga.nicovideo.jp/comic/#{@manga_id}")
          source.body.extend EBookloader::Extensions::String
          @books = source.body.global_match(%r{<li class="episode_item">.*?<div class="episode" data-number="(?<episode_num>[^"]*)"><div class="thumb episode_thumb"><a href="/watch/mg(?<id>[^\?]*)\?track=ct_episode"><img[^>]*><span[^>]*>(?<page>[^<]*)</span></a></div><div class="description"><div class="title"><a [^>]*>(?<episode>[^<]*)</a></div><div class="body "></div><div class="comment_summary ">(?<tags>[^<]*)</div><div class="counter">[^<]*</div></div></div>            </li>}m).map do |sc|
            id = sc[:id]
            episode = sc[:episode]
            episode_num = sc[:episode_num]
            Book::Seiga::Manga.new id, bookinfo.merge(episode: '%02d %s' % [episode_num, episode]).merge(@options)
          end

          true
        end
      end
    end
  end
end
