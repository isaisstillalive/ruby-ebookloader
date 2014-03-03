module EBookloader
  class Site
    class GanganOnline
      class Idolmaster < GanganOnline
        def initialize identifier, options = {}
          @identifier = identifier
          super 'idolmaster', options
        end

        private
        def lazy_load
          source = get @uri
          source.body.encode! Encoding::UTF_8, Encoding::Shift_JIS

          source.body.match %r{<div id="#{@identifier}"[^>]*>(?<body>.*?)<br style="clear:both;">}m do |match|
            body = match[:body]
            body.extend Extensions::String

            match = body.match(%r{<h3><img src="img/#{@identifier}_01.png" alt="(?<title>[^"]*?)" /></h3>.*?<p><img src="img/#{@identifier}_02.png" alt="(?<author>[^"]*?)" /></?p>}m)
            author = match[:author].gsub('漫画：', '').gsub('　脚本：', ' with ')
            merge title: match[:title], author: author

            @books = body.global_match(%r{<div class="viewerBox"[^>]*?>.*?<div class="viewerBoxSam">.*?<span>((?<episode_num>[^「]*?)\s*「(?<episode>[^」]*?)」|(?<episode>.*?))</span>.*?<!-- .viewerBoxSam --></div>.*?javascript:Fullscreen\('(?<uri>[^']*)'\);.*?<!-- \.viewerBox --></div>}m).map do |sc|
              uri = @uri + sc[:uri]
              episode = sc[:episode].gsub(/<[^>]*>/, ' ')
              episode = if sc[:episode_num]
                '%s %s' % [Site.get_episode_number(sc[:episode_num]), episode]
              else
                '%s' % [episode]
              end
              Book::ActiBook.new(uri, author: author, title: title, episode: episode)
            end
          end

          true
        end
      end
    end
  end
end
