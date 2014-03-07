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

    before{
      allow( book ).to receive(:update_from_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
    }

    it 'は書籍情報を更新する' do
      expect( book ).to receive(:update_from_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      subject
    end

    it 'は画像を設定する' do
      subject

      expect( book.page ).to eql URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.extension')
    end
  end

  describe '#update_from_illust_csv' do
    subject{ book.__send__ :update_from_illust_csv }

    it_behaves_like 'a BookInfo updater', title: 'title', author: 'member_name'

    before{
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
    }

    it 'はAPIからCSVを取得する' do
      expect( book ).to receive(:get_illust_csv).with('12345678').and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      subject
    end

    it 'はCSVを返却する' do
      expect( subject ).to eql response('/book/pixiv/illust.csv').body.parse_csv
    end
  end

  describe '#save_core' do
    let(:save_path){ Pathname('/path/file') }
    let(:save_file_path){ Pathname('/path/file.jpg') }
    subject{ book.__send__ :save_core, save_path }
    before{
      allow_any_instance_of( Pathname ).to receive(:exist?).and_return(true)
      allow_any_instance_of( Pathname ).to receive(:mkpath)

      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
    }

    it 'はファイルを読み込んで保存する' do
      expect( book ).to receive(:write).with(anything(), URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.extension'))
      subject
    end

    it 'はファイル名に拡張子を追加する' do
      book.instance_variable_set :@extension, 'jpg'
      expect( book ).to receive(:write).with(Pathname('/path/file.jpg'), anything())
      subject
    end

    context '保存ファイルのディレクトリが存在する場合' do
      it 'は保存ファイルのディレクトリを作成しない' do
        expect_any_instance_of( Pathname ).to receive(:exist?).and_return(true)
        expect_any_instance_of( Pathname ).to_not receive(:mkpath)
        subject
      end
    end

    context '保存ファイルのディレクトリが存在しない場合' do
      it 'は保存ファイルのディレクトリを作成する' do
        expect_any_instance_of( Pathname ).to receive(:exist?).and_return(false)
        expect_any_instance_of( Pathname ).to receive(:mkpath)
        subject
      end
    end
  end
end
