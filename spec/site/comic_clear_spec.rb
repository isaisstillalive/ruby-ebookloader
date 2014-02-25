# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::ComicClear do
  let(:site){ described_class.new 'identifier' }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://www.famitsu.com/comic_clear/identifier/')
    end
  end

  describe '#lazy_load' do
    it_behaves_like 'a Site#lazy_load @title'

    subject{ site.__send__ :lazy_load }

    before{
      allow( site ).to receive(:get).and_return(responce('/site/comic_clear/identifier.html'))
      site.instance_variable_set :@loaded, true
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://www.famitsu.com/comic_clear/identifier/')).and_return(responce('/site/comic_clear/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      # expect( site.books.size ).to eql 4
      books = site.books.to_a
      expect( books ).to eq [
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0001-0/index.html'),
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0002-0/index.html'),
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0003-0/index.html'),
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0004-0/index.html'),
      ]
      expect( books.map{ |book| book.name }.to_a ).to eql [
        'title 01 episode1',
        'title 02 episode2',
        'title 03.5 episode3.5',
        'title 04 episode4',
      ]
    end
  end
end
