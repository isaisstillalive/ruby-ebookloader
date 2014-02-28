# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Site do
  let(:site){ described_class.new 'uri' }
  let(:bookinfo){ site }

  it_behaves_like 'a LazyLoadable BookInfo'

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

    context '@uriとクラスが同じ場合' do
      let(:site1){ described_class.new('uri') }
      let(:site2){ described_class.new('uri') }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end

    context '@uriが異なる場合' do
      let(:site1){ described_class.new('uri1') }
      let(:site2){ described_class.new('uri2') }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'クラスが異なる場合' do
      let(:site1){ Site1.new('uri1') }
      let(:site2){ Site2.new('uri2') }

      it 'はfalseを返す' do
        expect( subject ).to eql false
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

  describe '.get_episode_number' do
    subject{ described_class.get_episode_number(episode) }

    context '不定形' do
      let(:episode){ '不定形' }

      it 'はそのまま返す' do
        expect( subject ).to eql '不定形'
      end
    end

    context '整数だけ' do
      let(:episode){ '1' }

      it 'は2桁にして返す' do
        expect( subject ).to eql '01'
      end
    end

    context '小数だけ' do
      let(:episode){ '1.1' }

      it 'は2.1桁にして返す' do
        expect( subject ).to eql '01.10'
      end
    end

    context '「第～話」' do
      let(:episode){ '第1話' }

      it 'は話数を返す' do
        expect( subject ).to eql '01'
      end
    end

    context '「第～回」' do
      let(:episode){ '第1回' }

      it 'は回数を返す' do
        expect( subject ).to eql '01'
      end
    end

    context '数が「n-m」' do
      let(:episode){ '第1-5話' }

      it 'はnn-mmを返す' do
        expect( subject ).to eql '01-05'
      end
    end
  end

  describe '.get_author' do
    subject{ described_class.get_author author }

    context '原案付きの場合' do
      let(:author){ '漫画：author1<br />原案：author2' }

      it 'は並列表記する' do
        expect( subject ).to eql 'author1, author2'
      end
    end

    context '作画・原作別の場合' do
      let(:author){ '原作/author1　作画/author2' }

      it 'は並列表記する' do
        expect( subject ).to eql 'author1, author2'
      end
    end
  end
end
