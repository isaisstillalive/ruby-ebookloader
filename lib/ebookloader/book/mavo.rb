# coding: utf-8

module EBookloader
  module Book
    class Mavo < Base
      include Book::MultiplePages

      def initialize identifier, options = {}
        uri =
          case options[:mode]
          when :pc
            "http://mavo.takekuma.jp/pcviewer.php?id=#{identifier}"
          when :ip1
            "http://mavo.takekuma.jp/ipviewer.php?id=#{identifier}"
          else
            "http://mavo.takekuma.jp/ipviewer2.php?id=#{identifier}"
          end

        super uri, options
      end

      private
      def lazy_load
        source = get @uri

        if source.headers['location']
          uri = @uri + source.headers['location']
          source = get uri
        end

        if options[:mode] == :pc
          update_without_overwrite source.body.match(%r{<title>(?<title>[^"]*?)  (?<episode>[^"]*?)</title>}).extend(Extensions::MatchData)
        else
          update_without_overwrite source.body.match(%r{<td align="center" id="title">(?<title>[^"]*?)<br/><span class="subtitle">(?:  )?(?<episode>[^"]*?)</span></td>}).extend(Extensions::MatchData)
        end

        source.body.extend EBookloader::Extensions::String
        page_options = options.dup
        page_options.delete(:mode)
        @pages = source.body.global_match(%r{path\[\d*\]='(?<uri>.*?(?<!iplast\.png)(?<!last\d\.png)(?<!howto\d\.png))';}).map.with_index 1 do |sc, page|
          Page.new @uri + sc[:uri], page_options.merge(page: page)
        end

        true
      end
    end
  end
end
