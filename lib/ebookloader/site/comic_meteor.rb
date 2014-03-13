# coding: utf-8

module EBookloader
  class Site
    class ComicMeteor < Base
      def initialize identifier, options = {}
        super "http://comic-meteor.jp/#{identifier}/", options
      end

      private

      def lazy_load
        source = get @uri

        authors = source.body.scan(%r{<h4 class="tit_04">.*?：(.*?)</h4>}m).flatten
        match = source.body.match(%r{<h2 class="h2Title">(?<title>.*?)</h2>}m)
        update_without_overwrite title: match[:title], author: authors

        source.body.extend EBookloader::Extensions::String
        @books = source.body.global_match(%r{<div class="totalinfo">\s*<div class="eachStoryText">\s*<h4>(?<episode>[^<]*?)</h4>.*?<a target="_new" href="(?<uri>[^""]*?)">読む</a>}m).reverse_each.map do |sc|
          uri = @uri + sc[:uri]
          Book::ActiBook.new(uri, bookinfo.merge(episode: sc[:episode]))
        end

        true
      end
    end
  end
end
