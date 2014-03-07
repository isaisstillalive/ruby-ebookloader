# coding: utf-8

require_relative '../spec_helper.rb'
require 'zip'

describe EBookloader::Book::MultiplePages do
  class MultiplePagesBook < EBookloader::Book::Base
    include EBookloader::Book::MultiplePages
  end

  let(:book){ MultiplePagesBook.new 'uri' }
  let(:bookinfo){ book }

  it_behaves_like 'a LazyLoadable', :pages, false

  describe '#save_core' do
    let(:dir){ Pathname('dir') }
    let(:options){ {} }
    let(:save_option){ {} }
    let(:page){ double('Page') }
    subject{ book.__send__ :save_core, dir, save_option }
    before{
      allow( book ).to receive(:name).and_return('name')
      allow( book ).to receive(:options).and_return(options)
      allow( book ).to receive(:pages).and_return([page])
      allow( page ).to receive(:save)

      allow_any_instance_of( Pathname ).to receive(:mkpath)
    }

    it 'はtrueを返す' do
      expect( subject ).to eql true
    end

    it 'はPage#saveを実行する' do
      expect( page ).to receive(:save).with(Pathname('dir/name'), 0)
      subject
    end

    context 'Page#pagesが複数の場合' do
      it 'はその数だけPage#saveを実行する' do
        page1 = double('Page')
        page2 = double('Page')
        expect( book ).to receive(:pages).and_return([page1, page2])
        expect( page1 ).to receive(:save).with(Pathname('dir/name'), 0)
        expect( page2 ).to receive(:save).with(Pathname('dir/name'), 0)
        subject
      end
    end

    context '保存オプションとしてオフセットが指定されている場合' do
      let(:save_option){ {offset: 2} }

      it 'はオフセットを渡して保存する' do
        expect( page ).to receive(:save).with(anything(), 2)
        subject
      end
    end

    context 'オプションとしてスライスが指定されている場合' do
      let(:options){ {slice: 1..3} }
      let(:pages){ Array.new(10){ double('Page') } }
      before{
        allow( book ).to receive(:pages).and_return(pages)
      }

      it 'は範囲内のページだけ保存する' do
        pages[1..3].each do |page|
          expect( page ).to receive(:save)
        end
        subject
      end

      it 'は先頭の分だけオフセットをズラす' do
        pages[1..3].each do |page|
          expect( page ).to receive(:save).with(anything(), -1)
        end
        subject
      end

      context '範囲の末尾がマイナスの場合' do
        let(:options){ {slice: 1..-1} }

        it 'は後ろから数える' do
          pages[1..8].each do |page|
            expect( page ).to receive(:save)
          end
          subject
        end
      end

      context '正の整数の場合' do
        let(:options){ {slice: 2} }

        it 'は先頭を捨てる' do
          pages[2..9].each do |page|
            expect( page ).to receive(:save).with(anything(), -2)
          end
          subject
        end
      end

      context '負の整数の場合' do
        let(:options){ {slice: -1} }

        it 'は末尾を捨てる' do
          pages[0..8].each do |page|
            expect( page ).to receive(:save).with(anything(), 0)
          end
          subject
        end
      end
    end

    context '保存ディレクトリが存在する場合' do
      it 'は保存ディレクトリを作成しない' do
        save_path = Pathname('dir/name')
        expect( dir ).to receive(:+).and_return(save_path)
        expect( save_path ).to receive(:exist?).and_return(true)
        expect( save_path ).to_not receive(:mkpath)
        subject
      end
    end

    context '保存ディレクトリが存在しない場合' do
      it 'は保存ディレクトリを作成する' do
        save_path = Pathname('dir/name')
        expect( dir ).to receive(:+).and_return(save_path)
        expect( save_path ).to receive(:exist?).and_return(false)
        expect( save_path ).to receive(:mkpath)
        subject
      end
    end

    context '保存時のオプションに zip: true を渡した場合' do
      subject{ book.__send__ :save_core, Pathname('dir'), zip: true }

      it 'は#zipを実行しzip圧縮する' do
        expect( book ).to receive(:zip).with(Pathname('dir/name')).and_return(true)
        subject
      end
    end
  end

  describe '#zip' do
    let(:dir_path){ Pathname('dir/name') }
    subject{ book.__send__ :zip, dir_path }
    before{
      allow(dir_path).to receive(:rmtree)
    }

    it 'はrubyzipを利用してzip圧縮を行う' do
      expect( Zip::File ).to receive(:open).with(Pathname('dir/name.zip'), Zip::File::CREATE)
      subject
    end

    it 'は指定したディレクトリの全てのファイルを圧縮する' do
      zip = double('zip')
      allow( dir_path ).to receive(:each_entry).and_yield(Pathname('1.jpg')).and_yield(Pathname('2.jpg'))
      expect( Zip::File ).to receive(:open).and_yield(zip)
      expect( zip ).to receive(:add).with('name/1.jpg', Pathname('dir/name/1.jpg'))
      expect( zip ).to receive(:add).with('name/2.jpg', Pathname('dir/name/2.jpg'))
      subject
    end

    it 'は指定したディレクトリを削除する' do
      zip = double('zip')
      allow( dir_path ).to receive(:each_entry)
      allow( Zip::File ).to receive(:open)
      expect(dir_path).to receive(:rmtree)
      subject
    end

    context 'パスが日本語の場合' do
      let(:dir_path){ Pathname('dir/日本語～') }

      it 'はShift_JISに変換する' do
        zip = double('zip')
        allow( dir_path ).to receive(:each_entry).and_yield(Pathname('1.jpg')).and_yield(Pathname('2.jpg'))
        expect( Zip::File ).to receive(:open).and_yield(zip)
        expect( zip ).to receive(:add).with('日本語～/1.jpg'.encode(Encoding::Shift_JIS, invalid: :replace, undef: :replace), Pathname('dir/日本語～/1.jpg'))
        expect( zip ).to receive(:add).with('日本語～/2.jpg'.encode(Encoding::Shift_JIS, invalid: :replace, undef: :replace), Pathname('dir/日本語～/2.jpg'))
        subject
      end
    end
  end

  describe '#<<' do
    subject{ book1 << book2 }

    let(:book1){ MultiplePagesBook.new('Book1') }
    let(:book2){ EBookloader::Book::Base.new('Book2') }

    before{
      book1.instance_variable_set :@pages, [
        EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1),
        EBookloader::Book::Page.new('Book1Page2', name: 'page2', page: 2),
      ]
      book2.instance_variable_set :@page, EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 1)
    }

    it 'は最初の本を返す' do
      expect( subject ).to eql book1
    end

    context '単ページの本が加えられた場合' do
      it 'は末尾にページを追加する' do
        subject
        expect( book1.pages ).to eq [
          EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1),
          EBookloader::Book::Page.new('Book1Page2', name: 'page2', page: 2),
          EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 3),
        ]
      end
    end

    context '複数ページの本が加えられた場合' do
      let(:book2){ MultiplePagesBook.new('Book2') }
      before{
        book2.instance_variable_set :@pages, [
          EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 1),
          EBookloader::Book::Page.new('Book2Page2', name: 'page2', page: 2),
        ]
      }

      it 'は末尾にページを追加する' do
        subject
        expect( book1.pages ).to eq [
          EBookloader::Book::Page.new('Book1Page1', name: 'page1', page: 1),
          EBookloader::Book::Page.new('Book1Page2', name: 'page2', page: 2),
          EBookloader::Book::Page.new('Book2Page1', name: 'page1', page: 3),
          EBookloader::Book::Page.new('Book2Page2', name: 'page2', page: 4),
        ]
      end
    end
  end

  describe '#dup' do
    subject{ book.dup }
    let(:pages){ [EBookloader::Book::Page.new('Page1', name: 'page1')] }
    before{
      book.instance_variable_set :@pages, pages
    }

    it 'はページも複製する' do
      expect( subject.pages ).to eq pages
      expect( subject.pages ).to_not eql pages
      expect( subject.pages[0] ).to eq pages[0]
      expect( subject.pages[0] ).to_not eql pages[0]
    end
  end

  describe '.extended' do
    let(:book){ EBookloader::Book::Base.new 'uri' }
    let(:page){ EBookloader::Book::Page.new('Page1') }
    before{
      book.instance_variable_set :@page, page
    }

    subject{ book.extend described_class }

    it 'は@pageを@pagesに変換する' do
      subject
      expect( book.instance_variable_get :@page ).to eql nil
      expect( book.pages ).to eql [page]
    end

    it 'は@pageを@pagesの1ページ目にする' do
      subject
      expect( book.pages[0] ).to eq EBookloader::Book::Page.new('Page1', page: 1)
    end

    context 'extendを複数回行った場合' do
      it 'は一度しか変換しない' do
        book.extend described_class
        subject
        expect( book.instance_variable_get :@page ).to eql nil
        expect( book.instance_variable_get :@pages ).to eql [page]
      end
    end
  end
end
