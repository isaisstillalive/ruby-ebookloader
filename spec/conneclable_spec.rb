# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Connectable do
    class ConnectableObject
        include EBookloader::Connectable
    end

    let(:connectable_object){ ConnectableObject.new }

    describe '#get' do
    	subject{ connectable_object.__send__ :get, URI('http://example.com/path'), {param: :param} }
        let(:faraday) { double 'faraday' }
        let(:conn){ double 'conn' }
        let(:get_options){ double 'get_options', headers: headers }
        let(:headers){ double 'headers' }

        it 'はFaraday#getを実行する' do
            expect( Faraday ).to receive(:new).with(url: 'http://example.com').and_yield(faraday).and_return(conn)
            expect( faraday ).to receive(:request).with(:url_encoded)
            expect( faraday ).to receive(:adapter).with(Faraday.default_adapter)
            expect( conn ).to receive(:get).with('/path', {param: :param}).and_yield(get_options).and_return( double('responce', {:body => 'body'}) )

            subject
        end
    end
end
