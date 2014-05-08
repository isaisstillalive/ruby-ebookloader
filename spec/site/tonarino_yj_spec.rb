# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::TonarinoYJ do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://tonarinoyj.jp/manga/identifier/')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).and_return(response('/site/tonarino_yj/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://tonarinoyj.jp/manga/identifier/')).and_return(response('/site/tonarino_yj/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/1/', img_server: 'http://img.tonarinoyj.jp/'),
        EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/1_5/', img_server: 'http://img.tonarinoyj.jp/'),
        EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/2/?viewer=vertical', img_server: 'http://img.tonarinoyj.jp/'),
        EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/extra-1/', img_server: 'http://img.tonarinoyj.jp/'),
        EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/extra-2/', img_server: 'http://img.tonarinoyj.jp/'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        'episode1',
        'episode1.5',
        'episode2',
        'extra_episode1',
        'extra_episode2',
      ]
    end
  end
end
