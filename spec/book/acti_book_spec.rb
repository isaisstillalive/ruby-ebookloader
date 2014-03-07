# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::ActiBook do
  let(:book){ described_class.new 'http://example.com/dir/_SWF_Window.html', option: :option }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }
    before{ book.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'name'

    before{
      allow( book ).to receive(:get).and_return(response('/book/acti_book/book.xml'))
    }

    it 'はbook.xmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://example.com/dir/books/db/book.xml')).and_return(response('/book/acti_book/book.xml'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::Page.new(URI('http://example.com/dir/books/images/2/1.jpg'), page: 1, extension: :jpg, option: :option),
        EBookloader::Book::Page.new(URI('http://example.com/dir/books/images/2/2.jpg'), page: 2, extension: :jpg, option: :option),
      ]
    end
  end
end
