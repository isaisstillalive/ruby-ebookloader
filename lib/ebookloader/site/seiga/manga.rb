# coding: utf-8

module EBookloader
  class Site
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

          rss = get URI("http://seiga.nicovideo.jp/rss/manga/#{@manga_id}")
          rss_doc = REXML::Document.new rss.body

          @books = rss_doc.get_elements('/rss/channel/item').reverse.map.with_index 1 do |image, episode_num|
            id = image.text('link').gsub(/^.*mg/, '')
            episode = image.text('title').gsub(/^#{title}\s/, '')
            Book::Seiga::Manga.new id, bookinfo.merge(episode: '%02d %s' % [episode_num, episode]).merge(@options)
          end

          true
        end
      end
    end
  end
end
