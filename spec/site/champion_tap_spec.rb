# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::ChampionTap do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://tap.akitashoten.co.jp/comics/identifier/')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).and_return(response('/site/champion_tap/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://tap.akitashoten.co.jp/comics/identifier/')).and_return(response('/site/champion_tap/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/1'),
        EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/2'),
        EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/3'),
        EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/4'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        'ep1 episode1',
        'ep2 episode2',
        'ep3 episode3',
        'ep4 episode4',
      ]
    end
  end
end
