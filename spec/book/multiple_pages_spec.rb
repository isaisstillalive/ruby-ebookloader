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
    let(:save_path){ Pathname('dirname') }
    subject{ book.__send__ :save_core, save_path }

    let(:options){ {} }

    let(:page){ double('Page') }

    before{
      allow( book ).to receive(:name).and_return('name')
      allow( book ).to receive(:options).and_return(options)
      allow( book ).to receive(:pages).and_return([page])

      allow( save_path ).to receive(:mkpath)

      allow( page ).to receive(:save)
    }

    it 'はtrueを返す' do
      expect( subject ).to eql true
    end

    it 'はPage#saveを実行する' do
      expect( page ).to receive(:save).with(1, save_path)
      subject
    end

    context 'Page#pagesが複数の場合' do
      it 'はその数だけPage#saveを実行する' do
        page1 = double('Page')
        page2 = double('Page')
        expect( book ).to receive(:pages).and_return([page1, page2])
        expect( page1 ).to receive(:save).with(1, save_path)
        expect( page2 ).to receive(:save).with(2, save_path)
        subject
      end
    end

    context 'オプションとしてオフセットが指定されている場合' do
      let(:options){ {offset: 2} }

      it 'はそのページ番号から保存を開始する' do
        expect( page ).to receive(:save).with(2, save_path)
        subject
      end
    end

    context '保存ディレクトリが存在する場合' do
      it 'は保存ディレクトリを作成しない' do
        expect( save_path ).to receive(:exist?).and_return(true)
        expect( save_path ).to_not receive(:mkpath)
        subject
      end
    end

    context '保存ディレクトリが存在しない場合' do
      it 'は保存ディレクトリを作成する' do
        expect( save_path ).to receive(:exist?).and_return(false)
        expect( save_path ).to receive(:mkpath)
        subject
      end
    end
  end
end
