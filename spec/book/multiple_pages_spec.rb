# coding: utf-8

require_relative '../spec_helper.rb'
require 'zip'

describe EBookloader::Book::MultiplePages do
  let(:book){ Object.new.extend described_class }
  let(:bookinfo){ book }

  it_behaves_like 'a LazyLoadable', :pages, false

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
      expect( page ).to receive(:save).with(save_path, 0)
      subject
    end

    context 'Page#pagesが複数の場合' do
      it 'はその数だけPage#saveを実行する' do
        page1 = double('Page')
        page2 = double('Page')
        expect( book ).to receive(:pages).and_return([page1, page2])
        expect( page1 ).to receive(:save).with(save_path, 0)
        expect( page2 ).to receive(:save).with(save_path, 0)
        subject
      end
    end

    context 'オプションとしてオフセットが指定されている場合' do
      let(:options){ {offset: 2} }

      it 'はオフセットを渡して保存する' do
        expect( page ).to receive(:save).with(save_path, 2)
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

    context '保存時のオプションに zip: true を渡した場合' do
      subject{ book.__send__ :save_core, save_path, zip: true }

      it 'は#zipを実行しzip圧縮する' do
        expect( book ).to receive(:zip).with(save_path).and_return(true)
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
  end
end
