# coding: utf-8

module EBookloader
  class Site
    class GanganOnline < Base
      def initialize identifier, options = {}
        super "http://www.ganganonline.com/comic/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri
        source.body.encode! Encoding::UTF_8, Encoding::Shift_JIS

        update_without_overwrite source.body.match(%r{<h2 class="iepngFixBg">(?<title>.*?)\s*<span class="titleYomi">\s*\((.*?)\)</span></h2>}).extend(Extensions::MatchData)

        source.body.match %r{<ul id="contentCenterBknmbrList">(?<list>.*?)</ul>}m do |match|
          list = match[:list]
          list.extend EBookloader::Extensions::String
          @books = list.global_match(%r{<li[^>]*?>【(?<episode_num>[^】]*?)】(?<episode>.*?)：<a [^>]*?onclick="javascript:Fullscreen\('(?<uri>[^']*?)'\);"[^>]*?>PC</a>}).map do |sc|
            uri = @uri + sc[:uri]
            episode = '%s %s' % [sc[:episode_num], sc[:episode]]
            Book::ActiBook.new(uri, bookinfo.merge(episode: episode))
          end
        end

        true
      end

      require_relative 'gangan_online/idolmaster'
    end
  end
end
