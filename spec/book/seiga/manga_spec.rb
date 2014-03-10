# coding: utf-8

require_relative '../../spec_helper.rb'
require 'csv'
#
describe EBookloader::Book::Seiga::Manga do
  let(:book){ described_class.new '12345678' }
  let(:bookinfo){ book }
  before{
    allow( book ).to receive(:write)
  }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( book ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/theme/info?id=12345678')).and_return(response('/book/seiga/theme_info.xml'))
      allow( book ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/theme/data?theme_id=12345678')).and_return(response('/book/seiga/theme_data.xml'))
      allow( book ).to receive(:get_author).and_return('author')
    }

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/theme/info?id=12345678')).and_return(response('/book/seiga/theme_info.xml'))
      expect( book ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/theme/data?theme_id=12345678')).and_return(response('/book/seiga/theme_data.xml'))
      subject
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::Page.new(URI('http://lohas.nicoseiga.jp/thumb/87654321p?'), extension: :jpg, page: 1),
        EBookloader::Book::Page.new(URI('http://lohas.nicoseiga.jp/thumb/87654322p?'), extension: :jpg, page: 2),
      ]
    end
  end
end
