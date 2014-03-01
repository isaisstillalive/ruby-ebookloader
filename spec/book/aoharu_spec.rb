# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Aoharu do
  let(:book){ described_class.new 'http://aoharu.jp/comic/identifier/1/' }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    before{
      allow( book ).to receive(:get).and_return(responce('/book/aoharu/1_vertical.html'))
    }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://aoharu.jp/comic/identifier/1/')).and_return(responce('/book/aoharu/1_vertical.html'))
      expect( subject ).to eql true
    end

    context '縦型ビューアの場合' do
      before{
        allow( book ).to receive(:get).and_return(responce('/book/aoharu/1_vertical.html'))
      }

      it 'は@pagesを設定する' do
        subject

        expect( book.pages ).to eq [
          EBookloader::Book::MultiplePages::Page.new(URI('http://aoharu.jp/comic/identifier/1/iPhone/ipad/1/1.jpg'), page: 1),
          EBookloader::Book::MultiplePages::Page.new(URI('http://aoharu.jp/comic/identifier/1/iPhone/ipad/1/2.jpg'), page: 2),
        ]
      end

      it 'は書籍情報を更新する' do
        expect( book ).to receive(:merge!).with(duck_type(:[])){ |arg|
          expect( arg[:title] ).to eql 'title'
          expect( arg[:author] ).to eql 'author'
          expect( arg[:episode] ).to eql 'episode'
        }
        subject
      end
    end

    context '横型ビューアの場合' do
      # before{
      #   allow( book ).to receive(:get).and_return(responce('/fixtures/aoharu/1_horizonal.html'))
      # }

      # it 'はsuperを使用する' do
      #   expect( book ).to receive(:lazy_load).and_return('super')
      #   expect( subject ).to eql 'super'
      # end
    end
  end
end
