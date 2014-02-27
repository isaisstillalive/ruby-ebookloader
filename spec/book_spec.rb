# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Book do
  let(:book){ described_class.new 'uri' }

  let(:bookinfo){ book }
  it_behaves_like 'a BookInfo'

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
    let(:dir_path){ Pathname('dir') }
    subject{ book.save 'dir' }
    before{
      allow_any_instance_of( Kernel ).to receive(:Pathname).and_return(dir_path)
      allow( dir_path ).to receive(:mkdir)
    }

    it 'は#save_coreを実行し戻り値を返す' do
      expect_any_instance_of( Kernel ).to receive(:Pathname).with('dir').and_return(dir_path)
      expect( book ).to receive(:save_core).with(dir_path).and_return(true)
      expect( subject ).to eql true
    end

    context '引数のディレクトリが存在する場合' do
      it 'はディレクトリを作成しない' do
        expect( dir_path ).to receive(:exist?).and_return(true)
        expect( dir_path ).to_not receive(:mkdir)
        subject
      end
    end

    context '引数のディレクトリが存在しない場合' do
      it 'はディレクトリを作成する' do
        expect( dir_path ).to receive(:exist?).and_return(false)
        expect( dir_path ).to receive(:mkdir)
        subject
      end
    end
  end
end
