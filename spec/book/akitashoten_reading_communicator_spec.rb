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

      expect( book.pages.size ).to eql 2
      expect( book.pages.to_a ).to eq [
        URI('http://tap.akitashoten.co.jp/comics/identifier/1/1'),
        URI('http://tap.akitashoten.co.jp/comics/identifier/1/2'),
      ]
    end

    context '@nameが設定されている場合' do
      before{ book.name = 'old_name' }

      it 'は@nameを設定しない' do
        subject
        expect( book.name ).to eql 'old_name'
      end
    end

    context '@nameが設定されていない場合' do
      it 'は@nameを設定する' do
        subject
        expect( book.name ).to eql '[author] title episode'
      end
    end
  end
end
