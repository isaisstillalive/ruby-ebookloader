# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::BookInfo do
  class Book
    include EBookloader::BookInfo
  end

  let(:book){ Book.new }
  let(:bookinfo){ book }

  it_behaves_like 'a LazyLoadable', :title, false
  it_behaves_like 'a LazyLoadable', :author, false

  describe '#title' do
    subject{ book.title }

    it 'は題名を返す' do
      book.title = 'title'
      expect( subject ).to eql 'title'
    end
  end

  describe '#author' do
    subject{ book.author }

    it 'は作者を返す' do
      book.author = 'author'
      expect( subject ).to eql 'author'
    end
  end

  describe '#name' do
    subject{ book.name }
    let(:title){ 'title' }
    let(:author){ 'author' }
    before{
      book.title = title
      book.author = author
    }

    it 'は作者と題名を結合して返す' do
      expect( subject ).to eql '[author] title'
    end

    it 'は名前をエスケープする' do
      expect( EBookloader::BookInfo ).to receive(:escape_name).with('[author] title').and_return('escaped')
      expect( subject ).to eql 'escaped'
    end

    context '題名が設定されていない場合' do
      let(:title){ nil }

      it 'は作者名を返す' do
        expect( subject ).to eql '[author]'
      end
    end

    context '作者が設定されていない場合' do
      let(:author){ nil }

      it 'は題名を返す' do
        expect( subject ).to eql 'title'
      end
    end

    context '題名も作者も設定されていない場合' do
      let(:title){ nil }
      let(:author){ nil }

      it 'は空文字を返す' do
        expect( subject ).to eql ''
      end
    end

    context '作者が複数設定されている場合' do
      let(:author){ ['author1', 'author2'] }

      it 'は作者をカンマで区切って返す' do
        expect( subject ).to eql '[author1, author2] title'
      end
    end

    context '先頭にスペースが入っている場合' do
      let(:title){ ' title' }
      let(:author){ nil }

      it 'は先頭のスペースを除去する' do
        expect( subject ).to eql 'title'
      end
    end

    context '末尾にスペースが入っている場合' do
      let(:title){ 'title ' }
      let(:author){ nil }

      it 'は末尾のスペースを除去する' do
        expect( subject ).to eql 'title'
      end
    end
  end

  describe '.escape_name' do
    subject{ EBookloader::BookInfo.escape_name 'abcde\/:*?"<>|あいうえお' }

    it 'はパス名として使用不可能な文字を全角に置換して返す' do
      expect( subject ).to eql 'abcde￥／：＊？”＜＞｜あいうえお'
    end
  end

  describe '#bookinfo' do
    subject{ book.__send__ :bookinfo }

    it 'は作者と題名をハッシュで返す' do
      book.title = 'title'
      book.author = 'author'
      expect( subject ).to eql(author: 'author', title: 'title')
    end
  end

  describe '#update_core' do
    let(:options){ { title: title, author: author, other: :other } }
    let(:title){ 'new_title' }
    let(:author){ 'new_author' }
    subject{ book.__send__ :update_core, options }
    before{
      book.title = 'title'
      book.author = 'author'
    }

    it 'は未処理のキーを含めたハッシュを返す' do
      expect( subject ).to eql({other: :other})
    end

    it 'は引数として渡したハッシュを変更しない' do
      subject
      expect( options ).to eql({ title: title, author: author, other: :other })
    end

    context 'オプション引数に題名がある場合' do
      it 'は題名を設定する' do
        subject
        expect( book.title ).to eql 'new_title'
      end

      context 'nilの場合' do
        let(:title){ nil }

        it 'はnilに設定する' do
          subject
          expect( book.title ).to eql nil
        end
      end
    end

    context 'オプション引数に題名がない場合' do
      subject{ book.__send__ :update_core, {} }

      it 'は題名を設定しない' do
        subject
        expect( book.title ).to eql 'title'
      end
    end

    context 'オプション引数に作者がある場合' do
      it 'は作者を設定する' do
        subject
        expect( book.author ).to eql 'new_author'
      end

      context 'nilの場合' do
        let(:author){ nil }

        it 'はnilに設定する' do
          subject
          expect( book.author ).to eql nil
        end
      end
    end

    context 'オプション引数に作者がない場合' do
      subject{ book.__send__ :update_core, {} }

      it 'は作者を設定しない' do
        subject
        expect( book.author ).to eql 'author'
      end
    end

    context 'オプション引数がnilの場合' do
      subject{ book.__send__ :update_core, nil }

      it 'は空のハッシュと同様に処理する' do
        expect( subject ).to eql({})
        expect( book.title ).to eql 'title'
        expect( book.author ).to eql 'author'
      end
    end

    context 'オプション引数がto_hashできる場合' do
      let(:hashed_object){ double('Hashed') }
      subject{ book.__send__ :update_core, hashed_object }

      it 'はハッシュと同様に処理する' do
        expect( hashed_object ).to receive(:to_hash).and_return(options)
        subject
        expect( book.title ).to eql 'new_title'
        expect( book.author ).to eql 'new_author'
      end
    end

    context '上書きしない場合' do
      subject{ book.__send__ :update_core, { title: 'new_title', author: 'new_author' }, false }

      it 'はすでに設定されている題名を設定しない' do
        subject
        expect( book.title ).to eql 'title'
      end

      it 'はすでに設定されている作者を設定しない' do
        subject
        expect( book.author ).to eql 'author'
      end
    end
  end

  describe '#update' do
    subject{ book.__send__ :update, title: 'new_title' }

    it 'は#update_coreを上書きモードで実行する' do
      expect( book ).to receive(:update_core).with({ title: 'new_title'}, true)
      subject
    end
  end

  describe '#update_without_overwrite' do
    subject{ book.__send__ :update_without_overwrite, title: 'new_title' }

    it 'は#update_coreを非上書きモードで実行する' do
      expect( book ).to receive(:update_core).with({ title: 'new_title'}, false)
      subject
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
