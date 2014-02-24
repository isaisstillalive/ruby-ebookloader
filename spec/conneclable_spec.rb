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
end
