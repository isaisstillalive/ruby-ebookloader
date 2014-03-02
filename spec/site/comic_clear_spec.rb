# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::ComicClear do
  let(:options){ {option: :option} }
  let(:site){ described_class.new 'identifier', options }

  describe '#uri' do
    subject{ site.uri }

    it 'はサイトのURIを取得する' do
      expect( subject ).to eql URI('http://www.famitsu.com/comic_clear/identifier/')
    end
  end

  describe '#lazy_load' do
    it_behaves_like 'a Site#lazy_load @title'

    subject{ site.__send__ :lazy_load }

    before{
      allow( site ).to receive(:get).and_return(response('/site/comic_clear/identifier.html'))
      site.instance_variable_set :@loaded, true
    }

    it 'はhtmlを取得する' do
      expect( site ).to receive(:get).with(URI('http://www.famitsu.com/comic_clear/identifier/')).and_return(response('/site/comic_clear/identifier.html'))
      expect( subject ).to eql true
    end

    it 'は本の情報を設定する' do
      subject
      expect( site.title ).to eql 'title'
      expect( site.author ).to eql 'author0, author1, author2, other1, other2'
    end

    it 'は@booksを設定する' do
      expect( site ).to receive(:get_episode).with('titleepisode1', 'title', options).and_return('episode1')
      expect( site ).to receive(:get_episode).with('titleepisode2', 'title', options).and_return('episode2')
      expect( site ).to receive(:get_episode).with('titleepisode3.5', 'title', options).and_return('episode3.5')
      expect( site ).to receive(:get_episode).with('titleepisode4', 'title', options).and_return('episode4')

      subject

      expect( site.books ).to eq [
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0001-0/index.html'),
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0002-0/index.html'),
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0003-0/index.html'),
        EBookloader::Book::FlipperU.new('http://ct.webcomic-eb.com/viewer/EB/identifier/0004-0/index.html'),
      ]
      expect( site.books.map{ |book| book.episode } ).to eql [
        '01 episode1',
        '02 episode2',
        '03.5 episode3.5',
        '04 episode4',
      ]
    end
  end

  describe '#get_episode' do
    let(:source){ 'titleepisode' }
    let(:options){ {} }
    subject{ site.__send__ :get_episode, source, 'title', options }

    it 'は文頭のタイトルを除去しエピソード名を返す' do
      expect( subject ).to eql 'episode'
    end

    context 'タイトルが除去できない場合' do
      let(:source){ 'notitleepisode' }

      it 'はそのまま返す' do
        expect( subject ).to eql 'notitleepisode'
      end
    end

    context 'プレフィックスが指定されている場合' do
      let(:source){ 'title_____episode' }
      let(:options){ { prefix: '_____' } }

      it 'はプレフィックスも除外して返す' do
        expect( subject ).to eql 'episode'
      end

      context 'プレフィックスが除去できない場合' do
        let(:source){ 'titlenoprefixepisode' }

        it 'はタイトルだけ除外して返す' do
          expect( subject ).to eql 'noprefixepisode'
        end
      end
    end

    context 'サフィックスが指定されている場合' do
      let(:source){ 'titleepisode-----' }
      let(:options){ { suffix: '-----' } }

      it 'はサフィックスも除外して返す' do
        expect( subject ).to eql 'episode'
      end

      context 'サフィックスが除去できない場合' do
        let(:source){ 'titleepisodenosuffix' }

        it 'はタイトルだけ除外して返す' do
          expect( subject ).to eql 'episodenosuffix'
        end
      end
    end
  end
end
