# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::MultiplePages do
  let(:book){ Object.new.extend described_class }

  describe '#pages' do
    subject{ book.pages }

    context '@pagesが設定されている場合' do
      before{ book.instance_variable_set(:@pages, ['pages']) }

      it 'は@pagesを返す' do
        expect( subject ).to eql ['pages']
      end
    end

    context '@pagesが設定されていない場合' do
      it 'は#lazy_loadを実行し、@pagesを返す' do
        def book.lazy_load
          @pages = ['pages']
          true
        end
        expect( book ).to receive(:lazy_load).and_call_original
        expect( subject ).to eql ['pages']
      end
    end
  end

  describe '#save_core' do
    let(:dir_path){ Pathname('dirname') }
    let(:save_dir_path){ Pathname('dirname/name') }
    subject{ book.__send__ :save_core, dir_path }

    let(:options){ {} }

    let(:page){ double('Page') }

    before{
      allow( book ).to receive(:name).and_return('name')
      allow( book ).to receive(:options).and_return(options)
      allow( book ).to receive(:pages).and_return([page])

      allow( save_dir_path ).to receive(:mkdir)
      allow( save_dir_path ).to receive(:exist?).and_return(true)

      allow( dir_path ).to receive(:+).with('name').and_return(save_dir_path)

      allow( page ).to receive(:save)
      allow( page ).to receive(:is_a?).with(EBookloader::Book::MultiplePages::Page).and_return(true)
      allow_any_instance_of( EBookloader::Book::MultiplePages::Page ).to receive(:save)
    }

    it 'はtrueを返す' do
      expect( subject ).to eql true
    end

    it 'は保存先パスに本の名前を足して保存ディレクトリとして使用する' do
      expect( page ).to receive(:save).with(1, save_dir_path)
      subject
    end

    it 'はpagesの数だけPage#saveを実行する' do
      page1 = double('Page')
      page2 = double('Page')
      expect( book ).to receive(:pages).and_return([page1, page2])
      expect( page1 ).to receive(:is_a?).with(EBookloader::Book::MultiplePages::Page).and_return(true)
      expect( page2 ).to receive(:is_a?).with(EBookloader::Book::MultiplePages::Page).and_return(true)
      expect( page1 ).to receive(:save).with(1, save_dir_path)
      expect( page2 ).to receive(:save).with(2, save_dir_path)
      subject
    end

    context 'オプションとしてオフセットが指定されている場合' do
      let(:options){ {offset: 2} }

      it 'はそのページ番号から保存を開始する' do
        expect( page ).to receive(:save).with(2, save_dir_path)
        subject
      end
    end

    context '保存ディレクトリが存在する場合' do
      it 'は保存ディレクトリを作成しない' do
        expect( save_dir_path ).to receive(:exist?).and_return(true)
        expect( save_dir_path ).to_not receive(:mkdir)
        subject
      end
    end

    context '保存ディレクトリが存在しない場合' do
      it 'は保存ディレクトリを作成する' do
        expect( save_dir_path ).to receive(:exist?).and_return(false)
        expect( save_dir_path ).to receive(:mkdir)
        subject
      end
    end
  end
end
