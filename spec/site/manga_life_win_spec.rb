# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::MangaLifeWin do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://mangalifewin.takeshobo.co.jp/identifier/')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=1')).and_return(response('/site/manga_life_win/book1.html'))
      allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=2')).and_return(response('/site/manga_life_win/book2.html'))
    }

    context 'ActiBook形式の場合' do
      it 'はhtmlを取得する' do
        expect( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=1')).and_return(response('/site/manga_life_win/book1.html'))
        expect( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=2')).and_return(response('/site/manga_life_win/book2.html'))
        expect( subject ).to eql true
      end

      it 'は@booksを設定する' do
        allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=1')).and_return(response('/site/manga_life_win/book1.html'))
        allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=2')).and_return(response('/site/manga_life_win/book2.html'))

        expect( EBookloader::Book::Base ).to receive(:get_episode_number).with('1').and_return('01').ordered
        expect( EBookloader::Book::Base ).to receive(:get_episode_number).with('#02').and_return('02').ordered
        expect( EBookloader::Book::Base ).to receive(:get_episode_number).with('#03').and_return('03').ordered

        subject

        expect( site.books ).to eq [
          EBookloader::Book::ActiBook.new('http://mangalifewin.takeshobo.co.jp/global-image/manga/identifier2/identifier/001/book/_SWF_Window.html'),
          EBookloader::Book::ActiBook.new('http://mangalifewin.takeshobo.co.jp/global-image/manga/identifier2/identifier/002/book/_SWF_Window.html'),
          EBookloader::Book::ActiBook.new('http://mangalifewin.takeshobo.co.jp/global-image/manga/identifier2/identifier/003/book/_SWF_Window.html'),
        ]
        expect( site.books.map(&:episode) ).to eql [
          '01',
          '02 episode02',
          '03 episode03',
        ]
      end
    end

    context 'ページ単位画像形式の場合' do
      it 'は@booksを設定する' do
        allow( site ).to receive(:get).with(URI('http://mangalifewin.takeshobo.co.jp/identifier/?page=1')).and_return(response('/site/manga_life_win/page.html'))

        expect( EBookloader::Book::Base ).to receive(:get_episode_number).with('1').and_return('01').ordered

        subject

        expect( site.books ).to eq [
          EBookloader::Book::Direct::Multiple.new('http://mangalifewin.takeshobo.co.jp/global-image/manga/identifier2/identifier/001/[00001-9].jpg'),
        ]
        expect( site.books.map(&:episode) ).to eql [
          '01',
        ]
      end
    end
  end
end
