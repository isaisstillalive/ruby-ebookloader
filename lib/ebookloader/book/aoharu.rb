# coding: utf-8

module EBookloader
  class Book
    class Aoharu < ActiBook
      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        return super if source.body.include? 'viewerNavi.js'

        self.merge! source.body.match %r{<h1><a href="[^"]*">(?<title>.*?)<span>\[作品紹介\]</span></a></h1><!-- \[!\] タイトル -->.*?<h2>(?<author>.*?)</h2><!-- \[!\] 作者 -->.*?<h3><span>(?<episode>.*?)</span></h3>}m

        @pages = source.body.scan(%r{<li><img src="(.*?)"(?: width="\d*" height="\d*")? class="undownload" ?/></li>}).map do |sc|
          Page.new @uri + sc[0]
        end

        true
      end
    end
  end
end
