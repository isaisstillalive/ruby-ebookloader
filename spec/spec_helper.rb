# coding: utf-8

require 'rubygems'

gem 'rspec'
require 'rspec'
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

begin
    gem 'simplecov'
    require 'simplecov'
    SimpleCov.start do
        add_filter 'spec'
    end
rescue Gem::LoadError
end

require_relative '../lib/ebookloader'

def html path
    IO.readlines("#{File.dirname(__FILE__)}/fixtures/#{path}", nil).first
end

def responce path
    RSpec::Mocks::Mock.new('responce', { :body => html(path) })
end

shared_examples_for 'a Site#lazy_load' do
    it_behaves_like 'a Site#lazy_load @title'
    it_behaves_like 'a Site#lazy_load @author'
end

shared_examples_for 'a Site#lazy_load @title' do
	let(:new_title){ 'title' }
	
    context '@titleが設定されている場合' do
        before{ site.title = 'old_title' }

        it 'は@titleを設定しない' do
            subject
            expect( site.title ).to eql 'old_title'
        end
    end

    context '@titleが設定されていない場合' do
        it 'は@titleを設定する' do
            subject
            expect( site.title ).to eql new_title
        end
    end
end

shared_examples_for 'a Site#lazy_load @author' do
    let(:new_author){ 'author' }
    
    context '@authorが設定されている場合' do
        before{ site.author = 'old_author' }

        it 'は@authorを設定しない' do
            subject
            expect( site.author ).to eql 'old_author'
        end
    end

    context '@authorが設定されていない場合' do
        it 'は@authorを設定する' do
            subject
            expect( site.author ).to eql new_author
        end
    end
end