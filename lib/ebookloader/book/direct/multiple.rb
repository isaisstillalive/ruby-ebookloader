# coding: utf-8

module EBookloader
  module Book
    class Direct
      class Multiple < Base
        include MultiplePages

        def initialize uri_pattern, options = {}
          @uri_pattern = uri_pattern
          @uri_pattern.extend Extensions::String
          @options = update(options)
        end

        private

        # 遅延読み込みを行う
        # @return [Boolean] 成功したか
        def lazy_load
          @pages = @uri_pattern.expand_each.map.with_index 1 do |(uri, values), page|
            page_options = {page: page}
            page_options[:name] = @options[:name].gsub(/#(\d+)/){ |val| values[$1.to_i - 1] } if @options[:name]

            Page.new URI(uri), options.merge(page_options)
          end

          true
        end
      end
    end
  end
end
