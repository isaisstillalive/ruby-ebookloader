# coding: utf-8

require_relative '../../spec_helper.rb'
require 'csv'

describe EBookloader::Site::Seiga::Manga do
  let(:site){ described_class.new '12345678' }
  let(:bookinfo){ site }

  describe '#manga_id' do
    subject{ site.manga_id }

    it 'はマンガIDを返却する' do
      expect( subject ).to eql '12345678'
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title:'title', author: 'author'

    before{
      allow( site ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/manga/info?id=12345678')).and_return(response('/site/seiga/manga_info.xml'))
      allow( site ).to receive(:get).with(URI('http://seiga.nicovideo.jp/rss/manga/12345678')).and_return(response('/site/seiga/rss_manga.xml'))
    }

    it 'はAPIからXMLを取得する' do
      expect( site ).to receive(:get).with(URI('http://seiga.nicovideo.jp/api/manga/info?id=12345678')).and_return(response('/site/seiga/manga_info.xml'))
      expect( site ).to receive(:get).with(URI('http://seiga.nicovideo.jp/rss/manga/12345678')).and_return(response('/site/seiga/rss_manga.xml'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::Seiga::Manga.new('87654321'),
        EBookloader::Book::Seiga::Manga.new('87654322'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        '01 episode1',
        '02 episode2',
      ]
    end

    context 'login_idとパスワードが設定されている場合' do
      let(:site){ described_class.new '12345678', login_id: :login_id, password: :password }

      it 'は@booksにlogin_idとパスワードを設定する' do
        subject

        expect( site.books ).to eq [
          EBookloader::Book::Seiga::Manga.new('87654321', login_id: :login_id, password: :password),
          EBookloader::Book::Seiga::Manga.new('87654322', login_id: :login_id, password: :password),
        ]
      end
    end
  end
end
