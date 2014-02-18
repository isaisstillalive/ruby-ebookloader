# coding: utf-8

require_relative '../lib/ebookloader'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def html path
    IO.readlines("#{File.dirname(__FILE__)}/fixtures/#{path}", nil).first
end

def responce path
    RSpec::Mocks::Mock.new('responce', { :body => html(path) })
end
