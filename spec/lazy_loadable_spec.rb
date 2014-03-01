# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::LazyLoadable do
  class LazyObject
    include EBookloader::LazyLoadable
  end

  let(:lazy_object){ LazyObject.new }

  describe '#load' do
    subject{ lazy_object.__send__ :load }

    it 'は#lazy_loadを呼び出す' do
      expect( lazy_object ).to receive(:lazy_load)
      subject
    end

    it 'は#lazy_loadがtrueを返した場合はそれ以上呼び出さない' do
      expect( lazy_object ).to receive(:lazy_load).once.and_return(true)
      lazy_object.__send__ :load
      subject
    end

    it 'は#lazy_loadがfalseを返した場合は再び呼び出す' do
      expect( lazy_object ).to receive(:lazy_load).twice.and_return(false)
      lazy_object.__send__ :load
      subject
    end

    it 'は#lazy_load内で#loadが呼ばれた場合には無視する' do
      def lazy_object.lazy_load
        load
        true
      end
      expect( lazy_object ).to receive(:lazy_load).once.and_call_original
      subject
    end

    it 'は#lazy_load内で例外が発生した場合は再び呼び出す' do
      expect( lazy_object ).to receive(:lazy_load).twice.and_raise "testError"
      lazy_object.__send__ :load rescue nil
      expect{ subject }.to raise_error "testError"
    end
  end

  describe '#lazy_load' do
    subject{ lazy_object.__send__ :lazy_load }

    it 'はtrueを返す' do
      expect( subject ).to eql true
    end
  end

  describe '.attr_lazy_reader' do
    before{
      class << lazy_object
        attr_lazy_reader :lazy_property

        def lazy_load
          @lazy_property = 'lazy_property'
          true
        end
      end
    }
    subject{ lazy_object.lazy_property }

    it 'は#loadを実行し、インスタンス変数を返すプロパティを作成する' do
      expect( lazy_object ).to receive(:lazy_load).once.and_call_original
      expect( subject ).to eql 'lazy_property'
    end
  end

  describe '.attr_lazy_accessor' do
    before{
      class << lazy_object
        attr_lazy_accessor :lazy_property

        def lazy_load
          @lazy_property = 'lazy_property'
          true
        end
      end
    }
    subject{ lazy_object.lazy_property }

    it 'は#loadを実行し、インスタンス変数を返すプロパティを作成する' do
      expect( lazy_object ).to receive(:load).once.and_call_original
      expect( subject ).to eql 'lazy_property'
    end

    it 'はインスタンス変数の値を設定できるプロパティを作成する' do
      lazy_object.lazy_property = 'old_value'
      expect( lazy_object ).to_not receive(:load)
      expect( subject ).to eql 'old_value'
    end
  end
end
