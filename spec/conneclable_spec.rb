# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Connectable do
  class ConnectableObject
    include EBookloader::Connectable
  end

  let(:connectable_object){ ConnectableObject.new }

  describe '#get' do
    subject{ connectable_object.__send__ :get, URI('http://example.com/path') }
    let(:faraday) { double 'faraday' }
    let(:conn){ double 'conn' }
    let(:get_options){ double 'get_options', headers: headers }
    let(:headers){ double 'headers' }
    before{
      allow( Faraday ).to receive(:new).with(url: 'http://example.com').and_return(conn)
      allow( headers ).to receive(:[]=).with('Connection', 'Keep-Alive')
    }

    it 'はFaraday#getを実行する' do
      expect( Faraday ).to receive(:new).with(url: 'http://example.com').and_yield(faraday).and_return(conn)
      expect( faraday ).to receive(:request).with(:url_encoded)
      expect( faraday ).to receive(:adapter).with(Faraday.default_adapter)
      expect( conn ).to receive(:get).with('/path', nil).and_yield(get_options).and_return( double('responce', {:body => 'body'}) )
      expect( headers ).to receive(:[]=).with('Connection', 'Keep-Alive')

      expect( subject.body ).to eql 'body'
    end

    context 'パラメータが渡されている場合' do
      subject{ connectable_object.__send__ :get, URI('http://example.com/path'), params: {param: :param} }

      it 'は#getにパラメータを渡す' do
        expect( conn ).to receive(:get).with('/path', param: :param)

        subject
      end
    end

    context 'ヘッダが渡されている場合' do
      subject{ connectable_object.__send__ :get, URI('http://example.com/path'), headers: {header: :header} }

      it 'は#getのオプションにヘッダを結合する' do
        allow( conn ).to receive(:get).with('/path', nil).and_yield(get_options).and_return( double('responce', {:body => 'body'}) )
        expect( headers ).to receive(:merge!).with({header: :header})

        subject
      end
    end
  end

  describe '#write' do
    let(:file_path){ Pathname('dir') }
    let(:file_pointer){ double(:file_pointer) }
    subject{ connectable_object.__send__ :write, file_path, URI('uri') }

    it 'は#getを実行した結果をファイルに書き込む' do
      expect( file_path ).to receive(:open).with('wb').and_yield(file_pointer)
      expect( connectable_object ).to receive(:get).with(URI('uri'), {}).and_return( double('response', {:body => 'body'}) )
      expect( file_pointer ).to receive(:write).with('body')
      subject
    end

    context 'オプションを渡している場合' do
    let(:options){ { headers: { header: :header }, other_options: {option: :option} } }
      subject{ connectable_object.__send__ :write, file_path, URI('uri'), options }

      it 'は#getにオプションを渡して実行する' do
        allow( file_path ).to receive(:open).with('wb').and_yield(file_pointer)
        expect( connectable_object ).to receive(:get).with(URI('uri'), options).and_return( double('response', {:body => 'body'}) )
        allow( file_pointer ).to receive(:write).with('body')
        subject
      end
    end
  end
end
