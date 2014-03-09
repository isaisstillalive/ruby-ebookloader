# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Site::Pixiv do
  let(:site){ described_class.new '12345678' }
  let(:bookinfo){ site }

  describe '#member_id' do
    subject{ site.member_id }

    it 'はメンバーIDを返却する' do
      expect( subject ).to eql '12345678'
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', author: 'author'

    before{
      allow( site ).to receive(:get_member_illist_csv).and_return(CSV.parse(response('/site/pixiv/member.csv').body))
      allow( site ).to receive(:get_member).and_return(response('/site/pixiv/profile.html'))
    }

    it 'はAPIからイラストCSVを取得する' do
      expect( site ).to receive(:get_member_illist_csv).with('12345678').and_return(CSV.parse(response('/book/pixiv/illust.csv').body))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::Pixiv.new('12345678'),
        EBookloader::Book::Pixiv::Manga.new('12345679'),
      ]
      expect( site.books.map(&:title) ).to eql [
        'title1',
        'title2',
      ]
    end

    context 'ログインIDとパスワードが設定されている場合' do
      let(:site){ described_class.new '12345678', login_id: :login_id, password: :password }

      it 'は@booksにログインIDとパスワードを設定する' do
        subject

        expect( site.books ).to eq [
          EBookloader::Book::Pixiv.new('12345678', login_id: :login_id, password: :password),
          EBookloader::Book::Pixiv::Manga.new('12345679', login_id: :login_id, password: :password),
        ]
      end
    end
  end
end
