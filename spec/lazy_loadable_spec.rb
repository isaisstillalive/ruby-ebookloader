# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::LazyLoadable do
  class LazyObject
    include EBookloader::LazyLoadable
  end

  let(:lazy_object){ LazyObject.new }
  let(:lazy_object_eigenclass){ (class << lazy_object; self; end) }

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
        def lazy_load
          @lazy_property = 'lazy_property'
          true
        end
      end
    }
    subject{ lazy_object_eigenclass.__send__ :attr_lazy_reader, :lazy_property }

    it 'は#loadを実行し、インスタンス変数を返すプロパティを作成する' do
      expect( lazy_object ).to receive(:lazy_load).once.and_call_original
      subject
      expect( lazy_object.lazy_property ).to eql 'lazy_property'
    end

    it 'はnilを返す' do
      expect( subject ).to eql nil
    end
  end

  describe 'attr_lazy_readerにより作成されたreaderメソッド' do
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

    context 'インスタンス変数が未設定の場合' do
      it 'はloadを実行する' do
        expect( lazy_object ).to receive(:load)
        subject
      end
    end

    context 'インスタンス変数が設定済みの場合' do
      it 'はloadを実行しない' do
        lazy_object.instance_variable_set :@lazy_property, 'lazy_property'
        expect( lazy_object ).to_not receive(:load)
        subject
      end
    end

    context 'インスタンス変数がnilの場合' do
      it 'はloadを実行しない' do
        lazy_object.instance_variable_set :@lazy_property, nil
        expect( lazy_object ).to_not receive(:load)
        subject
      end
    end
  end

  describe '.attr_lazy_accessor' do
    subject{ lazy_object_eigenclass.__send__ :attr_lazy_accessor, :lazy_property }

    it 'はattr_lazy_readerとattr_writerを実行する' do
      expect( lazy_object_eigenclass ).to receive(:attr_lazy_reader).with(:lazy_property)
      expect( lazy_object_eigenclass ).to receive(:attr_writer).with(:lazy_property)
      subject
    end

    it 'はnilを返す' do
      expect( subject ).to eql nil
    end
  end
end
