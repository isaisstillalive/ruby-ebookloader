# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::Base do
  let(:site){ described_class.new 'uri' }

  describe '初期化' do
    context 'URIが渡された場合' do
      it 'はURIをそのまま使用する' do
        book = described_class.new URI('http://example.com/')
        expect( book.instance_variable_get :@uri ).to eql URI('http://example.com/')
      end
    end

    context 'URI文字列が渡された場合' do
      it 'はURI文字列をURIにパースする' do
        book = described_class.new 'http://example.com/'
        expect( book.instance_variable_get :@uri ).to eql URI('http://example.com/')
      end
    end

    context '不正な文字列が渡された場合' do
      it 'は例外を発生させる' do
        expect{ described_class.new '日本語.com' }.to raise_error URI::InvalidURIError
      end
    end
  end

  describe '#uri' do
    subject{ site.uri }

    it 'は@uriを返す' do
      expect( subject ).to eql URI('uri')
    end
  end

  describe '#options' do
    subject{ site.options }

    context '初期化時にオプションを渡していない場合' do
      it 'は空のハッシュを返す' do
        expect( subject ).to eql({})
      end
    end

    context '初期化時にオプションを渡している場合' do
      let(:site){ described_class.new 'uri', options: 'options' }

      it 'はオプションのハッシュを返す' do
        expect( subject ).to eql({ options: 'options' })
      end
    end

    context '初期化時に題名、作者を渡している場合' do
      let(:site){ described_class.new 'uri', title: :title, author: :author, options: 'options' }

      it 'はそれらを除いたハッシュを返す' do
        expect( subject ).to eql({ options: 'options' })
      end
    end
  end

  describe '#==' do
    subject{ site1 == site2 }

    class Site1 < EBookloader::Site; end
    class Site2 < EBookloader::Site; end

    context '@uriとクラスとオプションが同じ場合' do
      let(:site1){ described_class.new('uri', title: :title, option: :option) }
      let(:site2){ described_class.new('uri', title: :title, option: :option) }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end

    context '@uriが異なる場合' do
      let(:site1){ described_class.new('uri1', title: :title, option: :option) }
      let(:site2){ described_class.new('uri2', title: :title, option: :option) }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'クラスが異なる場合' do
      let(:site1){ Site1.new('uri1', title: :title, option: :option) }
      let(:site2){ Site2.new('uri2', title: :title, option: :option) }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'オプションが異なる場合' do
      let(:site1){ described_class.new('uri', title: :title, option: :option1) }
      let(:site2){ described_class.new('uri', title: :title, option: :option2) }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context '書籍情報だけが異なる場合' do
      let(:site1){ described_class.new('uri', title: :title1, option: :option) }
      let(:site2){ described_class.new('uri', title: :title2, option: :option) }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end
  end

  describe '#books' do
    subject{ site.books }

    it 'は#lazy_loadを実行し、@booksを返す' do
      def site.lazy_load
        @books = ['books']
        true
      end
      expect( site ).to receive(:lazy_load).and_call_original
      expect( subject ).to eql ['books']
    end
  end
end
