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
  body = html(path)
  body.force_encoding Encoding::UTF_8
  RSpec::Mocks::Mock.new('response', { :body => body })
end

shared_examples_for 'a LazyLoadable' do |name, with_initialize|
  describe "\##{name}" do
    subject{ bookinfo.__send__ name }

    if with_initialize
      context "@#{name}が初期化されている場合" do
        let(:bookinfo){ described_class.new 'uri', { name => 'initialize_value' } }

        it "は@#{name}を返す" do
          expect( subject ).to eql 'initialize_value'
        end
      end
    end

    context "@#{name}が設定されている場合" do
      before{ bookinfo.instance_variable_set "@#{name}", 'update_value' }

      it "は@#{name}を返す" do
        expect( subject ).to eql 'update_value'
      end
    end

    context "@#{name}が設定されていない場合" do
      it "は#lazy_loadを実行し、@#{name}を返す" do
        expect( bookinfo ).to receive(:lazy_load).and_return(true) do
          bookinfo.instance_variable_set "@#{name}", 'update_value'
        end
        expect( subject ).to eql 'update_value'
      end
    end
  end
end

shared_examples_for 'a BookInfo updater' do |values|
  it 'は書籍情報を更新する' do
    expect( bookinfo ).to receive(:update_without_overwrite).with(duck_type(:[])){ |arg|
      values.each do |name, value|
        expect( arg[name] ).to eql value
      end
      bookinfo.__send__ :update_core, arg, true
    }
    subject
  end
end
