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

      def expand_each &block
        return enum_for(:expand_each) unless block_given?

        String.expand_each self, &block
      end

      def self.expand_each source, values = [], depth = 0, &block
        match = source.match /\[(?<first>[^\]\-]*)\-(?<last>[^\]\:]*)(?:\:(?<step>\d*))?\]|\{(?<choice>[^\}]*)\}/
        if match == nil
          yield source, values.dup
          return
        end

        replace_range = (match.begin(0))...(match.end(0))

        enum = if match[:choice].nil?
          range = Range.new match[:first], match[:last]
          step = match[:step] || 1
          range.step(step.to_i)
        else
          match[:choice].split(',')
        end

        enum.each do |value|
          text = source.dup
          text[replace_range] = value
          values[depth] = value

          expand_each text, values, depth+1, &block
        end
      end
    end
  end
end
