module EBookloader
  class Site
    class ComicClear < Site
      def initialize identifier, name = nil
        super "http://www.famitsu.com/comic_clear/#{identifier}/", name
      end

      private
      def lazy_load
        source = get @uri
        source.body.encode! Encoding::UTF_8, Encoding::Shift_JIS, :undef => :replace, :invalid => :replace

        self.merge! source.body.match(%r{<title>(?<title>.*?)\s+\| ファミ通コミッククリア</title>})

        source.body.match %r{<td width="140" class="main-right">(?<list>.*?)</td>}m do |match|
          search_title = Regexp.quote title
          @books = lazy_collection match[:list], %r{div class="mb\d*px"><a href="javascript:var objPcViewer=window\.open\('(?<uri>[^']*?)'[^"]*\)"><img src="../images/common/btn(?<episode_num>[^"]*).jpg" alt="#{search_title}(?<episode>[^"]*)" />}, true do |sc|
            uri = @uri + sc[:uri]
            name = '%s %s %s' % [self.name, sc[:episode_num], sc[:episode]]
            Book::FlipperU.new(uri, name: name)
          end
        end

        true
      end
    end
  end
end
