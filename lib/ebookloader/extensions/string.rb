# coding: utf-8

module EBookloader
  module Extensions
    module String
      def global_match pattern
        return enum_for(:global_match, pattern) unless block_given?

        pos = 0
        while last_match = pattern.match(self, pos)
          pos = last_match.end(0)
          yield last_match
        end

        self
      end
    end
  end
end
