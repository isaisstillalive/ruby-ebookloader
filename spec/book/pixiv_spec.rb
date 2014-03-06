# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Book::Pixiv do
  let(:book){ described_class.new '12345678', pixiv_id: 'pixiv_id', password: 'password' }
  let(:bookinfo){ book }
  before{
    allow( book ).to receive(:write)
  }

  describe '#illust_id' do
    subject{ book.illust_id }

    it 'はイラストIDを返却する' do
      expect( subject ).to eql '12345678'
    end
  end

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }
    before{ book.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'member_name'

    before{
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
    }

    it 'はAPIからCSVを取得する' do
      expect( book ).to receive(:get_illust_csv).with('12345678').and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      expect( subject ).to eql true
    end

    it 'は画像を設定する' do
      subject

      expect( book.page ).to eql URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.extension')
    end
  end

  describe '#save_core' do
    let(:save_path){ Pathname('/path/file') }
    let(:save_dir_path){ Pathname('/path/') }
    let(:save_file_path){ Pathname('/path/file') }
    subject{ book.__send__ :save_core, save_path }
    before{
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      allow( save_path ).to receive(:parent).and_return(save_dir_path)
      allow( save_dir_path ).to receive(:+).and_return(save_file_path)
      allow( save_file_path ).to receive(:parent).and_return(save_dir_path)
      allow( save_dir_path ).to receive(:mkpath)
      book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
    }

    it 'はファイルを読み込んで保存する' do
      expect( book ).to receive(:page).and_return(URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.png'))
      expect( book ).to receive(:write).with(save_file_path, URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.png'))
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
