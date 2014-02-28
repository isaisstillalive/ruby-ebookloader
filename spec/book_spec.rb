# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Book do
  let(:book){ described_class.new 'uri' }
  let(:bookinfo){ book }

  it_behaves_like 'a LazyLoadable BookInfo'

  describe '#uri' do
    subject{ book.uri }

    it 'は@uriを返す' do
      expect( subject ).to eql URI('uri')
    end
  end

  describe '#episode' do
    subject{ book.episode }

    context '@episodeが初期化されている場合' do
      let(:book){ described_class.new 'uri', episode: 'episode' }

      it 'は@episodeを返す' do
        expect( subject ).to eql 'episode'
      end
    end

    context '@episodeが設定されている場合' do
      before{ book.episode = 'episode' }

      it 'は@episodeを返す' do
        expect( subject ).to eql 'episode'
      end
    end

    context '@episodeが設定されていない場合' do
      it 'は#lazy_loadを実行し、@episodeを返す' do
        def book.lazy_load
          @episode = 'episode'
          true
        end
        expect( bookinfo ).to receive(:lazy_load).and_call_original
        expect( subject ).to eql 'episode'
      end
    end
  end

  describe '#name' do
    let(:book){ described_class.new 'uri', author: 'author', title: 'title', episode: 'episode' }
    subject{ book.name }

    it 'はBookInfo#nameとエピソードを結合して返す' do
      expect( subject ).to eql '[author] title episode'
    end

    context 'エピソードが設定されていない場合' do
      before{ book.instance_variable_set :@episode, nil }

      it 'はBookInfo#nameを返す' do
        expect( subject ).to eql '[author] title'
      end
    end
  end

  describe '#options' do
    subject{ book.options }

    context '初期化時にオプションを渡していない場合' do
      it 'は空のハッシュを返す' do
        expect( subject ).to eql({})
      end
    end

    context '初期化時にオプションを渡している場合' do
      let(:book){ described_class.new 'uri', options: 'options' }

      it 'はオプションのハッシュを返す' do
        expect( subject ).to eql({ options: 'options' })
      end
    end

    context '初期化時に題名、作者、エピソードを渡している場合' do
      let(:book){ described_class.new 'uri', title: :title, author: :author, episode: :episode, options: 'options' }

      it 'はそれらを除いたハッシュを返す' do
        expect( subject ).to eql({ options: 'options' })
      end
    end
  end

  describe '#==' do
    subject{ book1 == book2 }

    class Book1 < EBookloader::Book; end
    class Book2 < EBookloader::Book; end

    context '@uriとクラスが同じ場合' do
      let(:book1){ described_class.new('uri') }
      let(:book2){ described_class.new('uri') }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end

    context '@uriが異なる場合' do
      let(:book1){ described_class.new('uri1') }
      let(:book2){ described_class.new('uri2') }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'クラスが異なる場合' do
      let(:book1){ Book1.new('uri1') }
      let(:book2){ Book2.new('uri2') }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end
  end

  describe '#save' do
    subject{ book.save Pathname('dir') }
    before{
      allow( book ).to receive(:name).and_return('name')
    }

    it 'は#save_coreを実行し戻り値を返す' do
      allow( book ).to receive(:save_core).and_return(true)
      expect( subject ).to eql true
    end

    it 'は保存先パスに本の名前を足して保存パスとして使用する' do
      expect( book ).to receive(:save_core).with(Pathname('dir/name'))
      subject
    end

    context '保存先パスが文字列の場合' do
      subject{ book.save 'dir' }

      it 'はPathnameと同様に処理する' do
        expect( book ).to receive(:save_core).with(Pathname('dir/name'))
        subject
      end
    end
  end

  describe '#save_core' do
    subject{ book.__send__ :save_core, nil }

    it 'は常にtrueを返す' do
      expect( subject ).to eql true
    end
  end
end
