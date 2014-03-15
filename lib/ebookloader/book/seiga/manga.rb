# coding: utf-8

module EBookloader
  module Book
    class Seiga
      class Manga < Seiga
        include Book::MultiplePages

        private

        def lazy_load
          xml = get URI("http://seiga.nicovideo.jp/api/theme/info?id=#{@id}")
          doc = REXML::Document.new xml.body

          author = get_author doc.text('/response/theme/user_id') unless instance_variable_defined? :@author

          update_without_overwrite author: author, title: doc.text('/response/theme/content_title'), episode: doc.text('/response/theme/episode_title')

          pages_xml = get URI("http://seiga.nicovideo.jp/api/theme/data?theme_id=#{@id}")
          pages_doc = REXML::Document.new pages_xml.body
          @pages = pages_doc.get_elements('/response/image_list/image').map.with_index 1 do |page_data, page|
            Page.new page_data.text('source_url').gsub(/l\?$/, 'p?'), page: page
          end

          true
        end
      end
    end
  end
end
