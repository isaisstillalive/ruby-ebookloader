# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::Mavo do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://mavo.takekuma.jp/title.php?title=identifier')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'author'

    before{
      allow( site ).to receive(:get).and_return(response('/site/mavo/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://mavo.takekuma.jp/title.php?title=identifier')).and_return(response('/site/mavo/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::Mavo.new('001', mode: 'ip2'),
        EBookloader::Book::Mavo.new('002', mode: 'ip2'),
        EBookloader::Book::Mavo.new('003', mode: 'ip1'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        'episode1',
        'episode2',
        'episode3',
      ]
    end
  end
end
