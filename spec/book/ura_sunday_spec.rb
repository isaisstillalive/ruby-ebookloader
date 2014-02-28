# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::UraSunday do
  let(:book){ described_class.new 'http://urasunday.com/identifier/comic/001_001.html' }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://urasunday.com/identifier/comic/001_001.html')).and_return(response('/book/ura_sunday/001_001.html'))
      expect( subject ).to eql true
    end

    context '画像直指定の場合' do
      it_behaves_like 'a BookInfo updater', author: 'author', title: 'title', episode: 'episode'

      before{
        allow( book ).to receive(:get).and_return(response('/book/ura_sunday/001_001.html'))
      }

      it 'は@pagesを設定する' do
        subject

        expect( book.pages ).to eq [
          EBookloader::Book::MultiplePages::Page.new(URI('http://urasunday.com/comic/identifier/pc/001/001_001_01.jpg'), page: 1),
          EBookloader::Book::MultiplePages::Page.new(URI('http://urasunday.com/comic/identifier/pc/001/001_001_02.jpg'), page: 2),
        ]
      end
    end

    context '画像埋め込みの場合' do
      it_behaves_like 'a BookInfo updater', author: 'author', title: 'title', episode: 'episode'

      before{
        allow( book ).to receive(:get).and_return(response('/book/ura_sunday/002_002.html'))
      }

      it 'は@pagesを設定する' do
        subject

        expect( book.pages ).to eq [
          EBookloader::Book::MultiplePages::Page.new(URI('http://img.urasunday.com/eximages/comic/identifier/pc/002/002_002_01.jpg'), page: 1),
          EBookloader::Book::MultiplePages::Page.new(URI('http://img.urasunday.com/eximages/comic/identifier/pc/002/002_002_02.jpg'), page: 2),
        ]
      end
    end
  end
end
