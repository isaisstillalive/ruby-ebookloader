module EBookloader
  class Site
    class ComicMeteor < Site
      def initialize identifier, name = nil
        super "http://comic-meteor.jp/#{identifier}/", name
      end

      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        authors = source.body.scan(%r{<h4 class="tit_04">.*?：(.*?)</h4>}m)
        author = authors.flatten.join ', '
        match = source.body.match(%r{<h2 class="h2Title">(?<title>.*?)</h2>}m)
        self.merge! title: match[:title], author: author

        @books = lazy_collection source.body, %r{<div class="totalinfo">\s*<div class="eachStoryText">\s*<h4>(?<episode>[^<]*?)</h4>.*?<a target="_new" href="(?<uri>[^""]*?)">読む</a>}m, true do |sc|
          uri = @uri + sc[:uri]
          name = '%s %s' % [self.name, sc[:episode]]
          Book::ActiBook.new(uri, name: name)
        end

        true
      end
    end
  end
end
