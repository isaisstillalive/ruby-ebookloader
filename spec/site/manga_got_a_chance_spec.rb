# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::MangaGotAChance do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://mangag.com/manga/?p=identifier')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).with(URI('http://mangag.com/manga/?p=identifier')).and_return(response('/site/manga_got_a_chance/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://mangag.com/manga/?p=identifier')).and_return(response('/site/manga_got_a_chance/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=1')).and_return(response('/site/manga_life_win/book1.html'))
      allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=2')).and_return(response('/site/manga_life_win/book2.html'))

      subject

      expect( site.books ).to eq [
        EBookloader::Book::ActiBook.new('http://mangag.com/contents/viewer/identifier/episode1/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://mangag.com/contents/viewer/identifier/episode2/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://mangag.com/contents/viewer/identifier/episode3/_SWF_Window.html'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        'episode1',
        'episode2',
        'episode3',
      ]
    end
  end
end
