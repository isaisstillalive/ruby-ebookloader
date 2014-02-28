# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::FlipperU do
  let(:book){ described_class.new 'http://example.com/dir/index.html' }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it_behaves_like 'a BookInfo updater', title: 'title'

    before{
      allow( book ).to receive(:get).and_return(response('/book/flipper_u/book.xml'))
    }

    it 'はbook.xmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://example.com/dir/book.xml')).and_return(response('/book/flipper_u/book.xml'))
      expect( subject ).to eql true
    end

    it 'は@pagesを設定する' do
      expect( book ).to receive(:slice_count).with(kind_of(REXML::Elements), 'Width', 2).and_return(3).ordered
      expect( book ).to receive(:slice_count).with(kind_of(REXML::Elements), 'Height', 2).and_return(4).ordered

      subject

      expect( book.pages ).to eq [
        EBookloader::Book::FlipperU::Page.new(URI('http://example.com/dir/page1/page.xml'), page: 1, extension: :jpg, prefix: 'x', scale: 2, width: 3, height: 4, name: 'name1'),
        EBookloader::Book::FlipperU::Page.new(URI('http://example.com/dir/page2/page.xml'), page: 2, extension: :jpg, prefix: 'x', scale: 2, width: 3, height: 4),
        EBookloader::Book::FlipperU::Page.new(URI('http://example.com/dir/page3/page.xml'), page: 3, extension: :jpg, prefix: 'x', scale: 2, width: 3, height: 4, name: 'name3'),
      ]
    end
  end

  describe '#slice_count' do
    subject{ book.__send__ :slice_count, elements, 'Width', 2 }
    let(:elements){ double('Elements') }

    it 'は元画像のスケール倍を規定サイズで分割した時の枚数を返す' do
      expect( elements ).to receive(:[]).with('/setting/bookInformation/pageWidth').and_return(double('Element', text: '100')).ordered
      expect( elements ).to receive(:[]).with('/setting/bookInformation/sliceWidth').and_return(double('Element', text: '150')).ordered
      expect( subject ).to eql 2
    end
  end
end
