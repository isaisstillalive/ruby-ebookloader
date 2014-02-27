# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::DMangaOnline do
  let(:site){ described_class.new 'identifier' }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://d-manga.dengeki.com/work/identifier/')
    end
  end

  describe '#lazy_load' do
    it_behaves_like 'a Site#lazy_load'

    subject{ site.__send__ :lazy_load }

    before{
      allow( site ).to receive(:get).and_return(responce('/site/d_manga_online/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://d-manga.dengeki.com/work/identifier/')).and_return(responce('/site/d_manga_online/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      expect( EBookloader::Site ).to receive(:get_episode_number).with('1').and_return('01').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('4').and_return('04').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('3').and_return('03').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('2').and_return('02').ordered
      expect( EBookloader::Site ).to receive(:get_episode_number).with('1').and_return('01').ordered

      subject

      # expect( site.books.size ).to eql 4
      books = site.books.to_a
      expect( books ).to eq [
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_ex01/_SWF_Window.html'),
      ]
      expect( books.map{ |book| book.episode }.to_a ).to eql [
        '01',
        '02',
        '03',
        '04',
        '番外編 01',
      ]
      expect( books.map{ |book| book.options }.to_a ).to eql [
        {author: 'author', title: 'title', episode: '01', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html'}},
        {author: 'author', title: 'title', episode: '02', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html'}},
        {author: 'author', title: 'title', episode: '03', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html'}},
        {author: 'author', title: 'title', episode: '04', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html'}},
        {author: 'author', title: 'title', episode: '番外編 01', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_ex01/_SWF_Window.html'}},
      ]
    end

    context '番外編がない場合' do
      it 'は番外編以外で@booksを設定する' do
        expect( site ).to receive(:get).with(URI('http://d-manga.dengeki.com/work/identifier/')).and_return(responce('/site/d_manga_online/identifier_noextra.html'))

        expect( EBookloader::Site ).to receive(:get_episode_number).with('4').and_return('04').ordered
        expect( EBookloader::Site ).to receive(:get_episode_number).with('3').and_return('03').ordered
        expect( EBookloader::Site ).to receive(:get_episode_number).with('2').and_return('02').ordered
        expect( EBookloader::Site ).to receive(:get_episode_number).with('1').and_return('01').ordered

        subject

        # expect( site.books.size ).to eql 4
        books = site.books.to_a
        expect( books ).to eq [
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html'),
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html'),
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html'),
          EBookloader::Book::ActiBook.new('http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html'),
        ]
        expect( books.map{ |book| book.episode }.to_a ).to eql [
          '01',
          '02',
          '03',
          '04',
        ]
        expect( books.map{ |book| book.options }.to_a ).to eql [
          {author: 'author', title: 'title', episode: '01', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_01/_SWF_Window.html'}},
          {author: 'author', title: 'title', episode: '02', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_02/_SWF_Window.html'}},
          {author: 'author', title: 'title', episode: '03', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_03/_SWF_Window.html'}},
          {author: 'author', title: 'title', episode: '04', headers: {'Referer' => 'http://d-manga.dengeki.com/books/identifier_04/_SWF_Window.html'}},
        ]
      end
    end
  end
end
