# coding: utf-8

module EBookloader
  class Book
    class UraSunday < Base
      include Book::MultiplePages

      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        self.merge! source.body.match %r{<h1><a href="\.\./index.html" title=".*">(?<title>.*?)</a></h1>.*?<h2>(?<author>.*?)</h2>.*?<li class="comicTitleDate">(?<episode>.*?) ｜}m

        if source.body.include? '../../js/comic_write.js'
          base_uri = URI('http://img.urasunday.com/eximages/')
          match = source.body.match %r{var comic = '(?<comic>.*?)'.*?var imgid   = '(?<imgid>(?<dirid>.*?)_.*?)',.*?comicMax    = (?<page_count>\d*?);}m
          format = "./comic/#{match[:comic]}/pc/#{match[:dirid]}/#{match[:imgid]}_%02d.jpg"
        else
          base_uri = @uri
          match = source.body.match %r{for\(var i=1;i<=(?<page_count>\d*);i\+\+\).*?data-original="(?<dir>[^']*)' \+ agent \+ '(?<imgid>[^']*)' \+ vi \+ '(?<type>\.jpg)"}m
          format = "#{match[:dir]}pc#{match[:imgid]}%02d#{match[:type]}"
        end
        page_count = match[:page_count].to_i

        @pages = (1..page_count).to_enum{ page_count }.lazy.map do |page|
          base_uri + (format % [page])
        end

        true
      end
    end
  end
end
