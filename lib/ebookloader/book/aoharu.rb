# coding: utf-8

module EBookloader
  class Book
    class Aoharu < ActiBook
      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        return super if source.body.include? 'viewerNavi.js'

        merge source.body.match %r{<h1><a href="[^"]*">(?<title>.*?)<span>\[作品紹介\]</span></a></h1><!-- \[!\] タイトル -->.*?<h2>(?<author>.*?)</h2><!-- \[!\] 作者 -->.*?<h3><span>(?<episode>.*?)</span></h3>}m

        source.body.extend EBookloader::Extensions::String
        @pages = source.body.global_match(%r{<li><img src="(?<uri>.*?)"(?: width="\d*" height="\d*")? class="undownload" ?/></li>}).map.with_index 1 do |sc, page|
          Page.new @uri + sc[:uri], page: page
        end

        true
      end
    end
  end
end
