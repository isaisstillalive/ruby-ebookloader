# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Book::Seiga do
  let(:book){ described_class.new '12345678' }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }
    before{ book.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title'

    before{
      allow( book ).to receive(:get).and_return(response('/book/seiga/illust_info.xml'))
      head_response = double('Response')
      allow( book ).to receive(:head).and_return(head_response)
      allow(head_response).to receive(:[]).with(:location).and_return('http://lohas.nicoseiga.jp/o/123456789abcdef/12345678/12345678')
    }

    it 'はbook.xmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/illust/info?id=12345678')).and_return(response('/book/seiga/illust_info.xml'))
      expect( subject ).to eql true
    end

    it 'は@pageを設定する' do
      head_response = double('Response')
      expect( book ).to receive(:head).with(URI('http://seiga.nicovideo.jp/image/source/12345678')).and_return(head_response)
      expect(head_response).to receive(:[]).with(:location).and_return('http://lohas.nicoseiga.jp/o/123456789abcdef/12345678/12345678')

      subject

      expect( book.page ).to eq EBookloader::Book::Page.new(URI('http://lohas.nicoseiga.jp/priv/123456789abcdef/12345678/12345678'), name: 'title', extension: :jpg)
    end
  end
end
