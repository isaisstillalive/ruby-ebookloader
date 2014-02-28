# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::AkitashotenReadingCommunicator do
  let(:book){ described_class.new 'http://tap.akitashoten.co.jp/comics/identifier/1' }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    before{
      allow( book ).to receive(:get).and_return(responce('/book/akitashoten_reading_communicator/1.html'))
    }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://tap.akitashoten.co.jp/comics/identifier/1')).and_return(responce('/book/akitashoten_reading_communicator/1.html'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        URI('http://tap.akitashoten.co.jp/comics/identifier/1/1'),
        URI('http://tap.akitashoten.co.jp/comics/identifier/1/2'),
      ]
    end

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:merge!).with(duck_type(:[])){ |arg|
        expect( arg[:title] ).to eql 'title episode'
        expect( arg[:author] ).to eql 'author'
      }
      subject
    end
  end
end
