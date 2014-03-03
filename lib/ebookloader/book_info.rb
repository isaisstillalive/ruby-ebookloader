# coding: utf-8

module EBookloader
  module BookInfo
    attr_accessor :title, :author, :bookinfo

    def name
      return title unless author

      '[%s] %s' % [author, title]
    end

    def update options
      update_core options, false
    end

    def merge options
      update_core options, true
    end

    private
    def update_core options, merge = false
      return if options.nil?
      options = Hash[options]

      if options.include? :title
        @title = options[:title] unless merge && @title
        options.delete :title
      end
      if options.include? :author
        @author = options[:author] unless merge && @author
        options.delete :author
      end
      @bookinfo = {title: @title, author: @author}
      options
    end
  end
end
