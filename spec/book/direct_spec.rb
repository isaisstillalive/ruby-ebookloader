# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Direct do
  let(:book){ described_class.new 'http://example.com/file.jpg' }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:merge!).with(duck_type(:[])){ |arg|
        expect( arg[:title] ).to eql 'file.jpg'
      }
      subject
    end
  end

  describe '#save_core' do
    let(:save_path){ Pathname('/path/file.jpg') }
    let(:save_dir_path){ Pathname('/path/') }
    subject{ book.__send__ :save_core, save_path }
    before{
      allow( save_path ).to receive(:parent).and_return(save_dir_path)
      allow( save_dir_path ).to receive(:mkpath)
    }

    it 'はファイルを読み込んで保存する' do
      expect( book ).to receive(:write).with(save_path, URI('http://example.com/file.jpg'))
      subject
    end

    context '保存ファイルのディレクトリが存在する場合' do
      it 'は保存ファイルのディレクトリを作成しない' do
        expect( save_dir_path ).to receive(:exist?).and_return(true)
        expect( save_dir_path ).to_not receive(:mkpath)
        subject
      end
    end

    context '保存ファイルのディレクトリが存在しない場合' do
      it 'は保存ファイルのディレクトリを作成する' do
        expect( save_dir_path ).to receive(:exist?).and_return(false)
        expect( save_dir_path ).to receive(:mkpath)
        subject
      end
    end
  end
end
