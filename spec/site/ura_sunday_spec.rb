# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::UraSunday do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://urasunday.com/identifier/index.html')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).and_return(response('/site/ura_sunday/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://urasunday.com/identifier/index.html')).and_return(response('/site/ura_sunday/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/001_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/002_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/003_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/004_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/005_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/009_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/010_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/011_001.html'),
        EBookloader::Book::UraSunday.new('http://urasunday.com/identifier/comic/012_001.html'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        '1話',
        '2話',
        '3話',
        '4話',
        '5話',
        '9話',
        '10話',
        '11話',
        '12話',
      ]
    end
  end
end
