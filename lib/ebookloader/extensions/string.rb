# coding: utf-8

module EBookloader
  module Extensions
    module String
      def global_match pattern
        return to_enum(:global_match, pattern) unless block_given?

        pos = 0
        loop do
          match = pattern.match(self, pos)
          break if match.nil?

          pos = match.offset(0)[1]

          yield match
        end

        self
      end
    end
  end
end
