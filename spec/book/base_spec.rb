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

    it 'はエピソードをエスケープする' do
      allow( EBookloader::BookInfo ).to receive(:escape_name).with('[author] title').and_call_original
      expect( EBookloader::BookInfo ).to receive(:escape_name).with('episode').and_return('escaped')
      expect( subject ).to eql '[author] title escaped'
    end

    context 'エピソードが設定されていない場合' do
      before{ book.episode = nil }

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

  describe '#<<' do
    subject{ book1 << book2 }

    let(:book1){ described_class.new 'uri', author: 'author1', title: 'title1', episode: 'episode1' }
    let(:book2){ described_class.new 'uri', author: 'author2', title: 'title2', episode: 'episode2' }

    before{
      book1.instance_variable_set :@page, EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1)
      book2.instance_variable_set :@page, EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 1)
    }

    it 'は最初の本を返す' do
      expect( subject ).to eql book1
    end

    context '単ページの本が加えられた場合' do
      it 'は複数ページの本を返す' do
        expect( subject ).to be_a EBookloader::Book::Base
        expect( subject ).to be_a EBookloader::Book::MultiplePages
      end

      it 'はページを追加した複数ページの本を返す' do
        expect( subject.pages ).to eq [
          EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1),
          EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 2),
        ]
      end
    end

    context '複数ページの本が加えられた場合' do
      before{
        book2.extend EBookloader::Book::MultiplePages
        book2.instance_variable_set :@pages, [
          EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 1),
          EBookloader::Book::Page.new('Book2Page2', name: 'page2', page: 2),
        ]
      }

      it 'は複数ページの本を返す' do
        expect( subject ).to be_a EBookloader::Book::Base
        expect( subject ).to be_a EBookloader::Book::MultiplePages
      end

      it 'はページを追加した複数ページの本を返す' do
        expect( subject.pages ).to eq [
          EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1),
          EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 2),
          EBookloader::Book::Page.new('Book2Page2', name: 'page2', page: 3),
        ]
      end
    end
  end

  describe '#+' do
    subject{ book1 + book2 }

    let(:book1){ described_class.new 'uri', author: 'author1', title: 'title1', episode: 'episode1' }
    let(:book2){ described_class.new 'uri', author: 'author2', title: 'title2', episode: 'episode2' }
    let(:book1_clone){ book1.dup }

    before{
      book1.instance_variable_set :@pages, [
        EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1),
        EBookloader::Book::Page.new('Book1Page2', name: 'page2', page: 2),
      ]
      book2.instance_variable_set :@page, EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 1)

      allow( book1 ).to receive(:dup).and_return(book1_clone)
      allow( book1_clone ).to receive(:<<).and_return(book1_clone)
    }

    it 'は最初の本の複製を返す' do
      expect( subject ).to eq book1
      expect( subject ).to_not eql book1
    end

    it 'は合成する' do
      expect( book1_clone ).to receive(:<<).with(book2).and_return(book1_clone)
      subject
    end
  end

  describe '#save' do
    let(:options){ {option: :option} }
    subject{ book.save Pathname('dir'), options }

    it 'は#save_coreを実行し戻り値を返す' do
      expect( book ).to receive(:save_core).and_return(true)
      expect( subject ).to eql true
    end

    it 'は保存先パスを渡す' do
      expect( book ).to receive(:save_core).with(Pathname('dir'), anything())
      subject
    end

    context '保存先パスが文字列の場合' do
      subject{ book.save 'dir' }

      it 'はPathnameに変換して渡す' do
        expect( book ).to receive(:save_core).with(Pathname('dir'), anything())
        subject
      end
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
  end

  describe '#save_core' do
    let(:dir){ Pathname('dir') }
    subject{ book.__send__ :save_core, dir }
    before{
      allow( dir ).to receive(:mkpath)
      allow( book ).to receive(:page).and_return(double('Page'))
      allow( book.page ).to receive(:save)
    }

    it 'はファイルを読み込んで保存する' do
      expect( book.page ).to receive(:save).with(dir)
      subject
    end

    it 'はファイルを読み込んで保存する' do
      expect( book.page ).to receive(:save).with(dir)
      subject
    end

    it 'は成功したらtrueを返却する' do
      allow( book.page ).to receive(:save).and_return(true)
      expect( subject ).to eql true
    end

    context '保存ディレクトリが存在する場合' do
      it 'は保存ディレクトリを作成しない' do
        expect( dir ).to receive(:exist?).and_return(true)
        expect( dir ).to_not receive(:mkpath)
        subject
      end
    end

    context '保存ディレクトリが存在しない場合' do
      it 'は保存ディレクトリを作成する' do
        expect( dir ).to receive(:exist?).and_return(false)
        expect( dir ).to receive(:mkpath)
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

  describe '#dup' do
    subject{ book.dup }
    let(:page){ EBookloader::Book::Page.new('Page1', name: 'page1') }
    before{
      book.instance_variable_set :@page, page
    }

    it 'はページも複製する' do
      expect( subject.page ).to eq page
      expect( subject.page ).to_not eql page
    end
  end
end
