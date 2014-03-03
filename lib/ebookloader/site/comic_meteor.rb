module EBookloader
  class Site
    class ComicMeteor < Site
      def initialize identifier, options = {}
        super "http://comic-meteor.jp/#{identifier}/", options
      end

      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        authors = source.body.scan(%r{<h4 class="tit_04">.*?：(.*?)</h4>}m)
        author = authors.flatten.join ', '
        match = source.body.match(%r{<h2 class="h2Title">(?<title>.*?)</h2>}m)
        merge title: match[:title], author: author

        source.body.extend EBookloader::StringExtensions
        @books = source.body.global_match(%r{<div class="totalinfo">\s*<div class="eachStoryText">\s*<h4>(?<episode>[^<]*?)</h4>.*?<a target="_new" href="(?<uri>[^""]*?)">読む</a>}m).reverse_each.map do |sc|
          uri = @uri + sc[:uri]
          Book::ActiBook.new(uri, self.bookinfo.merge(episode: sc[:episode]))
        end

        true
      end
    end
  end
end
