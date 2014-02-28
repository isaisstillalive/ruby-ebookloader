# coding: utf-8

require_relative 'spec_helper.rb'

shared_examples_for 'a Faraday request' do |command, body|
  let(:uri){ URI('http://example.com/path') }
  let(:headers){ double('headers') }

  it 'はrun_requestを実行する' do
    expect( connectable_object ).to receive(:run_request).with(command, uri, body, headers).and_return( double('response', {:body => 'body'}) )

    expect( subject.body ).to eql 'body'
  end
end

describe EBookloader::Connectable do
  class ConnectableObject
    include EBookloader::Connectable
  end

  let(:connectable_object){ ConnectableObject.new }
  let(:faraday) { double 'faraday' }
  let(:conn){ double 'conn' }

  describe '#conn' do
    subject{ connectable_object.__send__ :conn, URI('http://example.com/path') }

    it 'はFaradayインスタンスを作成して返却する' do
      expect( Faraday ).to receive(:new).with(url: 'http://example.com', ssl: {verify: false} ).and_yield(faraday).and_return(conn)
      expect( faraday ).to receive(:request).with(:url_encoded)
      expect( faraday ).to receive(:adapter).with(Faraday.default_adapter)

      expect( subject ).to eql conn
    end
  end

  describe '#run_request' do
    subject{ connectable_object.__send__ :run_request, :method, URI('http://example.com/path') }

    let(:get_options){ double 'get_options', headers: headers }
    let(:headers){ {} }
    before{
      allow( connectable_object ).to receive(:conn).and_return(conn)
      allow( conn ).to receive(:run_request).and_yield(get_options).and_return( double('response', {:body => 'body'}) )
      allow( headers ).to receive(:[]=).with('Connection', 'Keep-Alive')
    }

    it 'はFaradayインスタンスを生成する' do
      expect( connectable_object ).to receive(:conn).with(URI('http://example.com/path')).and_return(conn)
      subject
    end

    it 'はFaraday#run_requestを実行する' do
      expect( conn ).to receive(:run_request).with(:method, '/path', nil, {}).and_yield(get_options).and_return( double('response', {:body => 'body'}) )

      expect( subject.body ).to eql 'body'
    end

    context 'ボディが渡されている場合' do
      subject{ connectable_object.__send__ :run_request, :method, URI('http://example.com/path'), 'request_body' }

      it 'はボディを渡す' do
        expect( conn ).to receive(:run_request).with(:method, '/path', 'request_body', {})

        subject
      end
    end

    context 'ヘッダが渡されている場合' do
      subject{ connectable_object.__send__ :run_request, :method, URI('http://example.com/path'), nil, header: :header }

      it 'はヘッダを渡す' do
        expect( conn ).to receive(:run_request).with(:method, '/path', nil, header: :header)

        subject
      end
    end
  end

  describe '#get' do
    subject{ connectable_object.__send__ :get, uri, headers }
    it_behaves_like 'a Faraday request', :get, nil
  end

  describe '#post' do
    subject{ connectable_object.__send__ :post, uri, 'body', headers }
    it_behaves_like 'a Faraday request', :post, 'body'
  end

  describe '#head' do
    subject{ connectable_object.__send__ :head, uri, headers }
    it_behaves_like 'a Faraday request', :head, nil
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

    context 'ヘッダを渡している場合' do
      let(:headers){ { header: :header } }
      subject{ connectable_object.__send__ :write, file_path, URI('uri'), headers }

      it 'は#getにヘッダを渡して実行する' do
        allow( file_path ).to receive(:open).with('wb').and_yield(file_pointer)
        expect( connectable_object ).to receive(:get).with(URI('uri'), headers).and_return( double('response', {:body => 'body'}) )
        allow( file_pointer ).to receive(:write).with('body')
        subject
      end
    end
  end
end
