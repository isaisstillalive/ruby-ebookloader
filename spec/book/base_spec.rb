# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Base do
  let(:book){ described_class.new 'uri' }
  let(:bookinfo){ book }

  it_behaves_like 'a LazyLoadable', :episode, true

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
    subject{ book.uri }

    it 'は@uriを返す' do
      expect( subject ).to eql URI('uri')
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

    class Book1 < described_class; end
    class Book2 < described_class; end

    context '@uriとクラスとオプションが同じ場合' do
      let(:book1){ described_class.new('uri', episode: :episode, option: :option) }
      let(:book2){ described_class.new('uri', episode: :episode, option: :option) }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end

    context '@uriが異なる場合' do
      let(:book1){ described_class.new('uri1', episode: :episode, option: :option) }
      let(:book2){ described_class.new('uri2', episode: :episode, option: :option) }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'クラスが異なる場合' do
      let(:book1){ Book1.new('uri', episode: :episode, option: :option) }
      let(:book2){ Book2.new('uri', episode: :episode, option: :option) }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'オプションが異なる場合' do
      let(:book1){ described_class.new('uri', episode: :episode, option: :option1) }
      let(:book2){ described_class.new('uri', episode: :episode, option: :option2) }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context '書籍情報だけが異なる場合' do
      let(:book1){ described_class.new('uri', episode: :episode1, option: :option) }
      let(:book2){ described_class.new('uri', episode: :episode2, option: :option) }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end
  end

  describe '#save' do
    let(:options){ {option: :option} }
    subject{ book.save Pathname('dir'), options }
    before{
      allow( book ).to receive(:name).and_return('name')
    }

    it 'は#save_coreを実行し戻り値を返す' do
      expect( book ).to receive(:save_core).and_return(true)
      expect( subject ).to eql true
    end

    it 'はオプションを渡す' do
      expect( book ).to receive(:save_core).with(anything(), {option: :option}).and_return(true)
      subject
    end

    context 'オプションがHash以外の場合' do
      let(:options){ double('Like A Hash') }

      it 'は#to_hashを用いてHashに変換する' do
        expect( options ).to receive(:to_hash).and_return({option: :option})
        expect( book ).to receive(:save_core).with(anything(), {option: :option}).and_return(true)
        subject
      end
    end

    it 'は保存先パスに本の名前を足して保存パスとして使用する' do
      expect( book ).to receive(:save_core).with(Pathname('dir/name'), anything())
      subject
    end

    context '保存先パスが文字列の場合' do
      subject{ book.save 'dir' }

      it 'はPathnameと同様に処理する' do
        expect( book ).to receive(:save_core).with(Pathname('dir/name'), anything())
        subject
      end
    end
  end

  describe '#update_core' do
    let(:options){ { title: title, author: author, episode: episode, other: :other } }
    let(:title){ 'new_title' }
    let(:author){ 'new_author' }
    let(:episode){ 'new_episode' }
    subject{ book.__send__ :update_core, options }
    before{
      book.episode = 'episode'
    }

    it 'は未処理のキーを含めたハッシュを返す' do
      expect( subject ).to eql({other: :other})
    end

    it 'は引数として渡したハッシュを変更しない' do
      subject
      expect( options ).to eql({ title: title, author: author, episode: episode, other: :other })
    end

    context 'オプション引数にエピソード名がある場合' do
      it 'はエピソード名を設定する' do
        subject
        expect( book.episode ).to eql 'new_episode'
      end

      context 'nilの場合' do
        let(:episode){ nil }

        it 'はnilに設定する' do
          subject
          expect( book.episode ).to eql nil
        end
      end
    end

    context 'オプション引数にエピソード名がない場合' do
      subject{ book.__send__ :update_core, {} }

      it 'は作者を設定しない' do
        subject
        expect( book.episode ).to eql 'episode'
      end
    end

    context '上書きしない場合' do
      subject{ book.__send__ :update_core, { episode: 'new_episode' }, false }

      it 'はすでに設定されているエピソード名を設定しない' do
        subject
        expect( book.episode ).to eql 'episode'
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
