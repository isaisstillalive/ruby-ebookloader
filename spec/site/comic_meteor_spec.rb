# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::ComicMeteor do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://comic-meteor.jp/identifier/')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author1, author2'

    before{
      allow( site ).to receive(:get).and_return(response('/site/comic_meteor/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://comic-meteor.jp/identifier/')).and_return(response('/site/comic_meteor/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::ActiBook.new('http://comic-meteor.jp/data/identifier/0001/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://comic-meteor.jp/data/identifier/0003/_SWF_Window.html'),
      ]
      expect( site.books.map{ |book| book.episode } ).to eql [
        'episode1',
        'episode3',
      ]
    end
  end
end
