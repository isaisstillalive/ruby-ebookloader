# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Site::Seiga do
  let(:site){ described_class.new '12345678' }
  let(:bookinfo){ site }

  describe '#id' do
    subject{ site.id }

    it 'はメンバーIDを返却する' do
      expect( subject ).to eql '12345678'
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', author: 'author'

    before{
      allow( site ).to receive(:get_author).with('12345678').and_return('author')
      allow( site ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/user/data?id=12345678')).and_return(response('/site/seiga/user_data.xml'))
    }

    it 'はAPIからXMLを取得する' do
      expect( site ).to receive(:get_author).with('12345678').and_return('author')
      expect( site ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/user/data?id=12345678')).and_return(response('/site/seiga/user_data.xml'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::Seiga.new('87654321'),
        EBookloader::Book::Seiga.new('87654322'),
      ]
      expect( site.books.map(&:title) ).to eql [
        'title1',
        'title2',
      ]
    end

    context 'login_idとパスワードが設定されている場合' do
      let(:site){ described_class.new '12345678', login_id: :login_id, password: :password }

      it 'は@booksにlogin_idとパスワードを設定する' do
        subject

        expect( site.books ).to eq [
          EBookloader::Book::Seiga.new('87654321', login_id: :login_id, password: :password),
          EBookloader::Book::Seiga.new('87654322', login_id: :login_id, password: :password),
        ]
      end
    end
  end
end
