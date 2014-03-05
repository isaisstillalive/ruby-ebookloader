# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::BookInfo do
  class Book
    include EBookloader::BookInfo
  end

  let(:book){ Book.new }
  let(:bookinfo){ book }
  before{
    book.title = 'title'
    book.author = 'author'
  }

  it_behaves_like 'a LazyLoadable', :title, false
  it_behaves_like 'a LazyLoadable', :author, false

  describe '#title' do
    subject{ book.title }

    it 'は題名を返す' do
      expect( subject ).to eql 'title'
    end
  end

  describe '#author' do
    subject{ book.author }

    it 'は作者を返す' do
      expect( subject ).to eql 'author'
    end
  end

  describe '#name' do
    subject{ book.name }

    it 'は作者と題名を結合して返す' do
      expect( subject ).to eql '[author] title'
    end

    context '作者が設定されていない場合' do
      before{ book.author = nil }

      it 'は題名を返す' do
        expect( subject ).to eql 'title'
      end
    end

    context '作者が複数設定されている場合' do
      before{ book.author = ['author1', 'author2'] }

      it 'は作者をカンマで区切って返す' do
        expect( subject ).to eql '[author1, author2] title'
      end
    end
  end

  describe '#bookinfo' do
    subject{ book.__send__ :bookinfo }

    it 'は作者と題名をハッシュで返す' do
      expect( subject ).to eql(author: 'author', title: 'title')
    end
  end

  describe '#update_core' do
    let(:options){ { title: title, author: author, other: :other } }
    let(:title){ 'new_title' }
    let(:author){ 'new_author' }
    subject{ book.__send__ :update_core, options }

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
end
