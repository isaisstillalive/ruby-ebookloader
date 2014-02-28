# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::EasyEPaperViewer do
  let(:book){ described_class.new 'http://example.com/dir/' }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( book ).to receive(:get).and_return(response('/book/easy_e_paper_viewer/config.xml'))
    }

    it 'はconfig.xmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://example.com/dir/config.xml')).and_return(response('/book/easy_e_paper_viewer/config.xml'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/img01.jpg'), page: 1),
        EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/img02.jpg'), page: 2),
        EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/img03.jpg'), page: 3),
      ]
    end

    context 'URIクエリにidが含まれる場合は' do
      let(:book){ described_class.new 'http://example.com/dir/?id=subdir' }

      it 'サブディレクトリからconfig.xmlを取得する' do
        expect( book ).to receive(:get).with(URI('http://example.com/dir/subdir/config.xml')).and_return(response('/book/easy_e_paper_viewer/config.xml'))
        subject
      end

      it '別のパスから画像を取得する' do
        subject

        expect( book.pages.size ).to eql 3
        expect( book.pages.to_a ).to eq [
          EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/subdir/img01.jpg'), page: 1),
          EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/subdir/img02.jpg'), page: 2),
          EBookloader::Book::MultiplePages::Page.new(URI('http://example.com/dir/subdir/img03.jpg'), page: 3),
        ]
      end
    end
  end
end
