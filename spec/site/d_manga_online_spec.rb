# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::DMangaOnline do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://d-manga.dengeki.com/work/identifier/')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).and_return(response('/site/d_manga_online/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://d-manga.dengeki.com/work/identifier/')).and_return(response('/site/d_manga_online/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      expect( EBookloader::Site ).to receive(:get_episode_number).with('1').and_return('01').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('2').and_return('02').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('3').and_return('03').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('4').and_return('04').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('1').and_return('01').ordered

      subject

      expect( site.books ).to eq [
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html'}),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html'}),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html'}),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html'}),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_ex01/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_ex01/_SWF_Window.html'}),
      ]
      expect( site.books.map(&:episode) ).to eql [
        '01',
        '02',
        '03',
        '04',
        '番外編 01',
      ]
    end

    context '番外編がない場合' do
      it 'は番外編以外で@booksを設定する' do
        expect( site ).to receive(:get).with(URI('http://d-manga.dengeki.com/work/identifier/')).and_return(response('/site/d_manga_online/identifier_noextra.html'))

        expect( EBookloader::Site ).to receive(:get_episode_number).with('1').and_return('01').ordered
        expect( EBookloader::Site ).to receive(:get_episode_number).with('2').and_return('02').ordered
        expect( EBookloader::Site ).to receive(:get_episode_number).with('3').and_return('03').ordered
        expect( EBookloader::Site ).to receive(:get_episode_number).with('4').and_return('04').ordered

        subject

        expect( site.books ).to eq [
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html'}),
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html'}),
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html'}),
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html'}),
        ]
        expect( site.books.map{ |book| book.episode } ).to eql [
          '01',
          '02',
          '03',
          '04',
        ]
      end
    end
  end
end
