# coding: utf-8

module EBookloader
    class Book
        class Aoharu < ActiBook
            private
            
            def lazy_load
            	source = get @uri
                source.body.force_encoding Encoding::UTF_8

                return super if source.body.include? 'viewerNavi.js'

                if @name.nil?
                    match = source.body.match /<h1><a href="[^"]*">(?<title>.*?)<span>\[作品紹介\]<\/span><\/a><\/h1><!-- \[!\] タイトル -->.*?<h2>(?<author>.*?)<\/h2><!-- \[!\] 作者 -->.*?<h3><span>(?<episode>.*?)<\/span><\/h3>/m
                    @name = '[%s] %s %s' % [match[:author], match[:title], match[:episode]]
                end

                page = 1
                @pages = source.body.to_enum(:scan, /<li><img src="(.*?)"(?: width="\d*" height="\d*")? class="undownload" ?\/><\/li>/).lazy.map do |sc|
                    uri = @uri + sc[0]
                    filename = '%03d.%s' % [page, 'jpg']
                    page += 1
                    [filename, uri]
                end

                true
            end
        end
    end
end
