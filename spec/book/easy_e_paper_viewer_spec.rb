# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::EasyEPaperViewer do
  let(:book){ described_class.new 'http://example.com/dir/' }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    before{
      allow( book ).to receive(:get).and_return(responce('/book/easy_e_paper_viewer/config.xml'))
    }

    it 'はconfig.xmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://example.com/dir/config.xml')).and_return(responce('/book/easy_e_paper_viewer/config.xml'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        URI('http://example.com/dir/img01.jpg'),
        URI('http://example.com/dir/img02.jpg'),
        URI('http://example.com/dir/img03.jpg'),
      ]
    end

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:merge!).with(duck_type(:[])){ |arg|
        expect( arg[:title] ).to eql 'title'
        expect( arg[:author] ).to eql 'author'
      }
      subject
    end

    context 'URIクエリにidが含まれる場合は' do
      let(:book){ described_class.new 'http://example.com/dir/?id=subdir' }

      it 'サブディレクトリからconfig.xmlを取得する' do
        expect( book ).to receive(:get).with(URI('http://example.com/dir/subdir/config.xml')).and_return(responce('/book/easy_e_paper_viewer/config.xml'))
        subject
      end

      it '別のパスから画像を取得する' do
        subject

        expect( book.pages.size ).to eql 3
        expect( book.pages.to_a ).to eq [
          URI('http://example.com/dir/subdir/img01.jpg'),
          URI('http://example.com/dir/subdir/img02.jpg'),
          URI('http://example.com/dir/subdir/img03.jpg'),
        ]
      end
    end
  end
end
