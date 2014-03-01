# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::AoharuOnline do
  let(:site){ described_class.new 'comic/identifier' }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://aoharu.jp/comic/identifier/')
    end
  end

  describe '#lazy_load' do
    it_behaves_like 'a Site#lazy_load'

    subject{ site.__send__ :lazy_load }

    before{
      allow( site ).to receive(:get).and_return(responce('/site/aoharu_online/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://aoharu.jp/comic/identifier/')).and_return(responce('/site/aoharu_online/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::Aoharu.new('http://aoharu.jp/comic/identifier/1/'),
        EBookloader::Book::Aoharu.new('http://aoharu.jp/comic/identifier/2/'),
        EBookloader::Book::Aoharu.new('http://aoharu.jp/comic/identifier/3/'),
        EBookloader::Book::Aoharu.new('http://aoharu.jp/comic/identifier/4/'),
        EBookloader::Book::Aoharu.new('http://aoharu.jp/comic/identifier/5/'),
      ]
      expect( site.books.map{ |book| book.episode } ).to eql [
        'ep1 episode1',
        'ep2',
        'ep3 episode3',
        'ep4',
        'ep5',
      ]
    end
  end
end
