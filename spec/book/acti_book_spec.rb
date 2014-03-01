# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::ActiBook do
  let(:book){ described_class.new 'http://example.com/dir/_SWF_Window.html' }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    before{
      allow( book ).to receive(:get).and_return(responce('/book/acti_book/book.xml'))
    }

    it 'はbook.xmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://example.com/dir/books/db/book.xml')).and_return(responce('/book/acti_book/book.xml'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/books/images/2/1.jpg'), page: 1, extension: :jpg),
        EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/books/images/2/2.jpg'), page: 2, extension: :jpg),
      ]
    end

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:merge!).with(duck_type(:[])){ |arg|
        expect( arg[:title] ).to eql 'name'
      }
      subject
    end
  end
end
