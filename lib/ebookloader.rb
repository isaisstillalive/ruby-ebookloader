# coding: utf-8

require 'uri'
require 'pathname'

require 'rubygems'
require 'faraday'

module EBookloader
  require_relative 'ebookloader/string_extender'
  require_relative 'ebookloader/connectable'
  require_relative 'ebookloader/lazy_loadable'
  require_relative 'ebookloader/book_info'
  require_relative 'ebookloader/book'
  require_relative 'ebookloader/site'
end
