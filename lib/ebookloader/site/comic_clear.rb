module EBookloader
  class Site
    class ComicClear < Base
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
        update_without_overwrite title: title, author: authors

        source.body.match %r{<td width="140" class="main-right">(?<list>.*?)</td>}m do |match|
          list = match[:list]
          list.extend EBookloader::Extensions::String
          @books = list.global_match(%r{div class="mb\d*px"><a href="javascript:var objPcViewer=window\.open\('(?<uri>[^']*?)'[^"]*\)"><img src="../images/common/btn(?<episode_num>[^"]*).jpg" alt="(?<episode>[^"]*)" />}).reverse_each.map do |sc|
            uri = @uri + sc[:uri]
            episode = '%s %s' % [sc[:episode_num], get_episode(sc[:episode], @title, @options)]
            Book::FlipperU.new(uri, self.bookinfo.merge(episode: episode))
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
