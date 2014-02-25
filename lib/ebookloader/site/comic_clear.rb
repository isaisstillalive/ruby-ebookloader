module EBookloader
  class Site
    class ComicClear < Site
      def initialize identifier, options = {}
        super "http://www.famitsu.com/comic_clear/#{identifier}/", options
      end

      private
      def lazy_load
        source = get @uri
        source.body.encode! Encoding::UTF_8, Encoding::Shift_JIS, :undef => :replace, :invalid => :replace

        match = source.body.match(%r{<meta name="keywords" content="(?:[^"]*(?:ファミ通|コミッククリア),)?(?<author>[^"]*)" />.*?<title>(?<title>.*?)\s+\| ファミ通コミッククリア</title>}m)
        title = match[:title]
        authors = match[:author].split(',')
        authors.delete(title)
        self.merge! title: title, author: authors.join(', ')

        source.body.match %r{<td width="140" class="main-right">(?<list>.*?)</td>}m do |match|
          @books = lazy_collection match[:list], %r{div class="mb\d*px"><a href="javascript:var objPcViewer=window\.open\('(?<uri>[^']*?)'[^"]*\)"><img src="../images/common/btn(?<episode_num>[^"]*).jpg" alt="(?<episode>[^"]*)" />}, true do |sc|
            uri = @uri + sc[:uri]
            name = '%s %s %s' % [self.name, sc[:episode_num], get_episode(sc[:episode], @title, @options)]
            Book::FlipperU.new(uri, name: name)
          end
        end

        true
      end

      def get_episode source, title, options = {}
        prefix = Regexp.quote options[:prefix].to_s
        suffix = Regexp.quote options[:suffix].to_s
        source.gsub %r{^#{Regexp.quote title}(?:#{prefix})?(.*?)(?:#{suffix})?$}, '\1'
      end
    end
  end
end
