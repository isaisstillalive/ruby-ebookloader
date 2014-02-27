# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::BookInfo do
  class Book
    include EBookloader::BookInfo
  end

  let(:book){ Book.new }
  before{
    book.instance_variable_set :@title, 'title'
    book.instance_variable_set :@author, 'author'
  }

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
      before{ book.instance_variable_set :@author, nil }

      it 'は題名を返す' do
        expect( subject ).to eql 'title'
      end
    end
  end

  describe '#bookinfo' do
    subject{ book.bookinfo }

    it 'は作者と題名をハッシュで返す' do
      expect( subject ).to eql(author: 'author', title: 'title')
    end
  end

  describe '#update_core' do
    let(:title){ 'new_title' }
    let(:author){ 'new_author' }
    subject{ book.__send__ :update_core, { title: title, author: author, other: :other } }

    it 'は未処理のキーを含めたハッシュを返す' do
      expect( subject ).to eql({other: :other})
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
        subject
        expect( book.title ).to eql 'title'
        expect( book.author ).to eql 'author'
      end
    end

    context 'オプション引数がMatchDataの場合' do
      subject{ book.__send__ :update_core, 'new_title'.match(/^(?<title>.*)$/) }

      it 'はハッシュと同様に処理する' do
        subject
        expect( book.title ).to eql 'new_title'
        expect( book.author ).to eql 'author'
      end
    end

    context 'マージの場合' do
      subject{ book.__send__ :update_core, { title: 'new_title', author: 'new_author' }, true }

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

  describe '#update!' do
    subject{ book.update! title: 'new_title' }

    it 'は#update_coreを非マージで実行する' do
      expect( book ).to receive(:update_core).with({ title: 'new_title'}, false)
      subject
    end
  end

  describe '#merge!' do
    subject{ book.merge! title: 'new_title' }

    it 'は#update_coreをマージで実行する' do
      expect( book ).to receive(:update_core).with({ title: 'new_title'}, true)
      subject
    end
  end
end
