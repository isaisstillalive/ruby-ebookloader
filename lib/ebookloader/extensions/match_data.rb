# coding: utf-8

module EBookloader
  module Extensions
    module MatchData
      def to_hash
        Hash[ names.map(&:to_sym).zip(captures) ]
      end
    end
  end
end
