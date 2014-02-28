# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::AkitashotenReadingCommunicator do
  let(:book){ described_class.new 'http://tap.akitashoten.co.jp/comics/identifier/1' }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it_behaves_like 'a BookInfo updater', title: 'title episode', author: 'author'

    before{
      allow( book ).to receive(:get).and_return(response('/book/akitashoten_reading_communicator/1.html'))
    }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://tap.akitashoten.co.jp/comics/identifier/1')).and_return(response('/book/akitashoten_reading_communicator/1.html'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::MultiplePages::Page.new(URI('http://tap.akitashoten.co.jp/comics/identifier/1/1'), page: 1),
        EBookloader::Book::MultiplePages::Page.new(URI('http://tap.akitashoten.co.jp/comics/identifier/1/2'), page: 2),
      ]
    end
  end
end
