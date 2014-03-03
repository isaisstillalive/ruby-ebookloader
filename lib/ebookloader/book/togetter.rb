# coding: utf-8

module EBookloader
  class Book
    class Togetter < Book
      include Book::MultiplePages

      private

      def lazy_load
        source = get @uri
        source.body.force_encoding Encoding::UTF_8

        merge source.body.match(%r{<h1>\s*<a class="info_title" href="[^"]*" title="(?<title>[^"]*)"}m)

        id = @uri.to_s.match(%r{^http://togetter\.com/li/(?<id>[^/]*)})[:id]
        csrf_token = source.body.match(%r{<meta name="csrf_token" content="(?<csrf_token>[^"]*)"/>})[:csrf_token]
        tweets = get URI("http://togetter.com/api/moreTweets/#{id}?page=1&csrf_token=#{csrf_token}")
        tweets.body.force_encoding Encoding::UTF_8
        body = tweets.body

        body.extend EBookloader::StringExtensions
        @pages = body.global_match(%r{<div class='list_photo'><a[^>]*?><img src="(?<uri>[^"]*)" /></a></div>}m).map.with_index 1 do |sc, page|
          Page.new URI(sc[:uri] + ':large'), page: page, extension: Pathname(sc[:uri]).extname[1..-1].to_sym
        end

        true
      end
    end
  end
end
