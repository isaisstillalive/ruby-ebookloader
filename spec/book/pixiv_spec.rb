# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Book::Pixiv do
  let(:book){ described_class.new '12345678', pixiv_id: 'pixiv_id', password: 'password' }
  let(:bookinfo){ book }
  before{
    allow( book ).to receive(:write)
  }

  describe '#illust_id' do
    subject{ book.illust_id }

    it 'はイラストIDを返却する' do
      expect( subject ).to eql '12345678'
    end
  end

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }
    before{ book.instance_variable_set :@loaded, true }

    before{
      allow( book ).to receive(:update_from_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
    }

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:update_from_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      subject
    end

    it 'は@pageを設定する' do
      book.title = 'title'
      book.author = 'author'
      subject

      expect( book.page ).to eq EBookloader::Book::Page.new(URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.extension'), extension: 'extension', name: '[author] title', headers: { 'Referer' => 'http://www.pixiv.net/' })
    end
  end

  describe '#update_from_illust_csv' do
    subject{ book.__send__ :update_from_illust_csv }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'member_name'

    before{
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
    }

    it 'はAPIからCSVを取得する' do
      expect( book ).to receive(:get_illust_csv).with('12345678').and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      subject
    end

    it 'はCSVを返却する' do
      expect( subject ).to eql response('/book/pixiv/illust.csv').body.parse_csv
    end
  end
end
