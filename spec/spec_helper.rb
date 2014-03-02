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

def response path
  RSpec::Mocks::Mock.new('response', { :body => html(path) })
end

shared_examples_for 'a BookInfo' do
  describe '#title' do
    subject{ bookinfo.title }

    context '@titleが初期化されている場合' do
      let(:bookinfo){ described_class.new 'uri', title: 'title' }

      it 'は@titleを返す' do
        expect( subject ).to eql 'title'
      end
    end

    context '@titleが設定されている場合' do
      before{ bookinfo.title = 'title' }

      it 'は@titleを返す' do
        expect( subject ).to eql 'title'
      end
    end

    context '@titleが設定されていない場合' do
      it 'は#lazy_loadを実行し、@titleを返す' do
        def bookinfo.lazy_load
          @title = 'title'
          true
        end
        expect( bookinfo ).to receive(:lazy_load).and_call_original
        expect( subject ).to eql 'title'
      end
    end
  end

  describe '#author' do
    subject{ bookinfo.author }

    context '@authorが初期化されている場合' do
      let(:bookinfo){ described_class.new 'uri', author: 'author' }

      it 'は@authorを返す' do
        expect( subject ).to eql 'author'
      end
    end

    context '@authorが設定されている場合' do
      before{ bookinfo.author = 'author' }

      it 'は@authorを返す' do
        expect( subject ).to eql 'author'
      end
    end

    context '@authorが設定されていない場合' do
      it 'は#lazy_loadを実行し、@authorを返す' do
        def bookinfo.lazy_load
          @author = 'author'
          true
        end
        expect( bookinfo ).to receive(:lazy_load).and_call_original
        expect( subject ).to eql 'author'
      end
    end
  end
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
