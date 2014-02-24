# coding: utf-8

module EBookloader
    module BookInfo
        attr_accessor :title, :author

        def name
            return title unless author

            '[%s] %s' % [author, title]
        end

        def update! options
            update_core options, false
        end

        def merge! options
            update_core options, true
        end

        private
        def update_core options, merge = false
            if options.is_a? MatchData
                options = Hash[ options.names.map{|name| name.to_sym }.zip( options.captures ) ]
            else
                options ||= {}
            end
            if options.include? :title
                @title = options[:title] unless merge && @title
            end
            if options.include? :author
                @author = options[:author] unless merge && @author
            end
        end
    end
end
