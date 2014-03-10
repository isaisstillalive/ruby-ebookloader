# coding: utf-8

module EBookloader
  module Book
    class Seiga
      class Manga < Seiga
        include Book::MultiplePages

        private

        def lazy_load
          xml = get URI("http://seiga.nicovideo.jp/api/theme/info?id=#{@illust_id}")
          doc = REXML::Document.new xml.body

          author = get_author doc.text('/response/theme/user_id') unless instance_variable_defined? :@author

          update_without_overwrite author: author, title: doc.text('/response/theme/title'), episode: doc.text('/response/theme/episode_title')

          pages_xml = get URI("http://seiga.nicovideo.jp/api/theme/data?theme_id=#{@illust_id}")
          pages_doc = REXML::Document.new pages_xml.body
          @pages = pages_doc.get_elements('/response/image_list/image').map do |page|
            Page.new page.text('source_url').gsub(/l\?$/, 'p?'), page: page.text('leaf').to_i
          end

          true
        end
      end
    end
  end
end
