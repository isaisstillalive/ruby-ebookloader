# coding: utf-8

require_relative '../../spec_helper.rb'
require 'csv'

describe EBookloader::Book::Pixiv::Manga do
  let(:book){ described_class.new '12345678', pixiv_id: 'pixiv_id', password: 'password' }
  before{
    allow( book ).to receive(:write)
  }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    before{
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/manga.csv').body.parse_csv)
      book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
    }

    it 'はAPIからCSVを取得する' do
      expect( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/manga.csv').body.parse_csv)
      expect( subject ).to eql true
    end

    it 'はCSVから書籍情報を更新する' do
      expect( book ).to receive(:merge).with(duck_type(:[])){ |arg|
        expect( arg[:title] ).to eql 'title'
        expect( arg[:author] ).to eql 'member_name'
      }
      subject
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::MultiplePages::Page.new(URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111_big_p0.extension'), page: 1, extension: :extension, headers: {'Referer' => 'http://www.pixiv.net/'}),
        EBookloader::Book::MultiplePages::Page.new(URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111_big_p1.extension'), page: 2, extension: :extension, headers: {'Referer' => 'http://www.pixiv.net/'}),
        EBookloader::Book::MultiplePages::Page.new(URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111_big_p2.extension'), page: 3, extension: :extension, headers: {'Referer' => 'http://www.pixiv.net/'}),
      ]
    end
  end
end
