# coding: utf-8

require_relative '../../spec_helper.rb'

describe EBookloader::Site::GanganOnline::Idolmaster do
  let(:site){ described_class.new 'identifier' }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://www.ganganonline.com/comic/idolmaster/')
    end
  end

  describe '@identifier' do
    subject{ site.instance_variable_get :@identifier }

    it 'はidentifierを保持する' do
      expect( subject ).to eql 'identifier'
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }

    before{
      allow( site ).to receive(:get).and_return(response('/site/gangan_online/idolmaster.html'))
      site.instance_variable_set :@loaded, true
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://www.ganganonline.com/comic/idolmaster/')).and_return(response('/site/gangan_online/idolmaster.html'))
      expect( subject ).to eql true
    end

    it 'は題名を設定する' do
      subject
      expect( site.title ).to eql 'title'
    end

    it 'は作者を設定する' do
      subject
      expect( site.author ).to eql 'author'
    end

    it 'は@booksを設定する' do
      allow( site ).to receive(:title).and_return('title')
      expect( EBookloader::Book::Base ).to receive(:get_episode_number).with('第1話').and_return('01')
      expect( EBookloader::Book::Base ).to receive(:get_episode_number).with('第2話').and_return('02')

      subject

      expect( site.books ).to eq [
        EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/idolmaster/identifier/001/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/idolmaster/identifier/002/_SWF_Window.html'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        '01 episode1',
        '02 episode2',
      ]
    end

    context '別のidentifierの場合' do
      let(:site){ described_class.new 'identifier2' }

      it 'は題名を設定する' do
        subject
        expect( site.title ).to eql 'title2'
      end

      it 'は作者を設定する' do
        subject
        expect( site.author ).to eql 'author2'
      end

      it 'は@booksを設定する' do
        allow( site ).to receive(:title).and_return('title2')
        expect( EBookloader::Book::Base ).to_not receive(:get_episode_number)

        subject

        # expect( site.books.size ).to eql 2
        books = site.books.to_a
        expect( books ).to eq [
          EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/idolmaster/identifier2/001/_SWF_Window.html'),
        ]
        expect( books.map(&:episode) ).to eql [
          'episode2-1 episode2-2',
        ]
      end
    end
  end
end
