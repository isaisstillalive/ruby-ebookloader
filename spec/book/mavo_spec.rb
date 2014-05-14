# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Mavo do
  let(:book){ described_class.new 'identifier', option: :option }
  let(:bookinfo){ book }

  describe '初期化' do
    context '種別が指定されている場合' do
      context 'pcの場合' do
        let(:book){ described_class.new 'identifier', mode: :pc }

        it 'はPCのhtmlを指定する' do
          expect( book.uri ).to eql URI('http://mavo.takekuma.jp/pcviewer.php?id=identifier')
        end
      end

      context 'ip1の場合' do
        let(:book){ described_class.new 'identifier', mode: :ip1 }

        it 'はiPhone見開きのhtmlを指定する' do
          expect( book.uri ).to eql URI('http://mavo.takekuma.jp/ipviewer.php?id=identifier')
        end
      end

      context 'ip2の場合' do
        let(:book){ described_class.new 'identifier', mode: :ip2 }

        it 'はiPhoneスクロールのhtmlを指定する' do
          expect( book.uri ).to eql URI('http://mavo.takekuma.jp/ipviewer2.php?id=identifier')
        end
      end
    end
  end

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }
    before{ book.instance_variable_set :@loaded, true }

    before{
      allow( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/pcviewer.php?id=identifier')).and_return(response('/book/mavo/pc.html'))
      allow( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer.php?id=identifier')).and_return(response('/book/mavo/ip1.html'))
      allow( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer2.php?id=identifier')).and_return(response('/book/mavo/ip2.html'))
    }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer2.php?id=identifier')).and_return(response('/book/mavo/ip2.html'))
      expect( subject ).to eql true
    end

    context 'リダイレクトする種別の場合' do
      it 'は他の種別のhtmlを取得する' do
        expect( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer.php?id=identifier')).and_return(response('/book/mavo/ip1.html'))
        expect( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer2.php?id=identifier')).and_return(double('Response', headers: {'location' => 'ipviewer.php?id=identifier'}))
        expect( subject ).to eql true
      end
    end

    context '種別がip1の場合' do
      let(:book){ described_class.new 'identifier', mode: :ip1 }

      it_behaves_like 'a BookInfo updater', title: 'title', episode: 'episode'

      it 'は@pagesを設定する' do
        expect( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer.php?id=identifier')).and_return(response('/book/mavo/ip1.html'))

        subject

        expect( book.pages ).to eq [
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/001.png'), page: 1, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/002.png'), page: 2, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/003.png'), page: 3, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/004.png'), page: 4, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/005.png'), page: 5, extension: :png),
        ]
      end
    end

    context '種別がip2の場合' do
      let(:book){ described_class.new 'identifier', mode: :ip2 }

      it_behaves_like 'a BookInfo updater', title: 'title', episode: 'episode'

      it 'は@pagesを設定する' do
        expect( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/ipviewer2.php?id=identifier')).and_return(response('/book/mavo/ip2.html'))

        subject

        expect( book.pages ).to eq [
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/001.png'), page: 1, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/002.png'), page: 2, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/003.png'), page: 3, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/004.png'), page: 4, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/005.png'), page: 5, extension: :png),
        ]
      end
    end

    context '種別がpcの場合' do
      let(:book){ described_class.new 'identifier', mode: :pc }

      it_behaves_like 'a BookInfo updater', title: 'title', episode: 'episode'

      it 'は@pagesを設定する' do
        expect( book ).to receive(:get).with(URI('http://mavo.takekuma.jp/pcviewer.php?id=identifier')).and_return(response('/book/mavo/pc.html'))

        subject

        expect( book.pages ).to eq [
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/001.png'), page: 1, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/002.png'), page: 2, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/003.png'), page: 3, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/004.png'), page: 4, extension: :png),
          EBookloader::Book::Page.new(URI('http://blog-randmax.azurewebsites.net/manga/chisen/identifier/005.png'), page: 5, extension: :png),
        ]
      end
    end
  end
end
