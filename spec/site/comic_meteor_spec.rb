# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::ComicMeteor do
  let(:site){ described_class.new 'identifier' }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://comic-meteor.jp/identifier/')
    end
  end

  describe '#lazy_load' do
    it_behaves_like 'a Site#lazy_load @title'
    it_behaves_like 'a Site#lazy_load @author' do
      let(:new_author){ 'author1, author2' }
    end

    subject{ site.__send__ :lazy_load }

    before{
      allow( site ).to receive(:get).and_return(responce('/site/comic_meteor/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://comic-meteor.jp/identifier/')).and_return(responce('/site/comic_meteor/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      # expect( site.books.size ).to eql 2
      expect( site.books.to_a ).to eq [
        EBookloader::Book::ActiBook.new('http://comic-meteor.jp/data/identifier/0001/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://comic-meteor.jp/data/identifier/0003/_SWF_Window.html'),
      ]
      expect( site.books.map{ |book| book.name }.to_a ).to eql [
        '[author1, author2] title episode1',
        '[author1, author2] title episode3',
      ]
    end
  end
end
