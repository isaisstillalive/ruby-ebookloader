# coding: utf-8

module EBookloader
  class Site
    class Pixiv < Base
      include Connectable::Pixiv

      attr_reader :member_id

      def initialize member_id, options = {}
        @member_id = member_id
        super
      end

      private

      def lazy_load
        source = get_member @member_id

        update_without_overwrite source.body.match(%r{<tr><th>ニックネーム<td>(?<author>[^<]*?)$}m).extend(Extensions::MatchData)

        csv = get_member_illist_csv @member_id

        @books = csv.reverse.map do |line|
          klass = line[19].nil? ? Book::Pixiv : Book::Pixiv::Manga
          klass.new(line[0], bookinfo.merge(title: line[3], episode: nil).merge(@options))
        end

        true
      end
    end
  end
end
