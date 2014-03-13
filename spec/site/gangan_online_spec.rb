# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::GanganOnline do
  let(:site){ described_class.new 'identifier' }
  let(:bookinfo){ site }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://www.ganganonline.com/comic/identifier/')
    end
  end

  describe '#lazy_load' do
    subject{ site.__send__ :lazy_load }
    before{ site.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title'

    before{
      allow( site ).to receive(:get).and_return(response('/site/gangan_online/identifier.html'))
      site.instance_variable_set :@loaded, true
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://www.ganganonline.com/comic/identifier/')).and_return(response('/site/gangan_online/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は@booksを設定する' do
      subject

      expect( site.books ).to eq [
        EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/identifier/001/_SWF_Window.html'),
        EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/identifier/002/_SWF_Window.html'),
      ]
      expect( site.books.map(&:episode) ).to eql [
        'ep1 episode1',
        'ep2 episode2',
      ]
    end
  end
end
