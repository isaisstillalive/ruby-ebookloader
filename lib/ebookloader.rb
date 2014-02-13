require 'uri'
require 'pathname'

require 'rubygems'
require 'faraday'

module EBookloader
    require_relative 'ebookloader/connectable'
    require_relative 'ebookloader/lazy_loadable'
    require_relative 'ebookloader/book'
    require_relative 'ebookloader/site'
end
