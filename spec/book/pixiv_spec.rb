# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Book::Pixiv do
  let(:book){ described_class.new '12345678', pixiv_id: 'pixiv_id', password: 'password' }
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

    before{
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
    }

    it 'はAPIからCSVを取得する' do
      expect( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      expect( subject ).to eql true
    end

    it 'はCSVから書籍情報を更新する' do
      allow( book ).to receive(:get_illust_csv).and_return(response('/book/pixiv/illust.csv').body.parse_csv)
      expect( book ).to receive(:merge).with(duck_type(:[])){ |arg|
        expect( arg[:title] ).to eql 'title'
        expect( arg[:author] ).to eql 'member_name'
      }
      subject
    end

    it 'は画像を設定する' do
      subject

      expect( book.page ).to eql URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.extension')
    end
  end

  describe '#pixiv_request' do
    subject{ book.__send__ :pixiv_request, :method, uri }
    let(:uri){ double('URI') }
    before{
      allow( book ).to receive(:login)
      allow( book ).to receive(:run_request)
    }

    it 'はSESSIONIDを渡してFaradayにアクセスする' do
      book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
      expect( book ).to receive(:run_request).with(:method, uri, {})
      subject
    end
  end

  describe '#get_illust_csv' do
    subject{ book.__send__ :get_illust_csv }

    it 'はPixivにアクセスしてCSVを取得する' do
      book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
      expect( book ).to receive(:pixiv_request).with(:get, URI('http://spapi.pixiv.net/iphone/illust.php?illust_id=12345678&PHPSESSID=0123456789abcdef0123456789abcdef')).and_return(response('/book/pixiv/illust.csv'))

      expect( subject ).to eq [
        '11111111',
        'member_id',
        'extension',
        'title',
        '999',
        'member_name',
        'thumbnail_image_uri',
        nil,
        nil,
        'medium_image_uri',
        nil,
        nil,
        'update_date',
        'tag1 tag2',
        'tool',
        'vote_count',
        'vote_total',
        'pv',
        'description',
        'page_max',
        nil,
        nil,
        '123',
        '3',
        'member_nick_id',
        nil,
        '1',
        nil,
        nil,
        'member_profile_image_uri',
        nil,
      ]
    end
  end

  describe '#session' do
    subject{ book.__send__ :session }

    it 'はセッションIDを返す' do
      book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'

      expect( subject ).to eql '0123456789abcdef0123456789abcdef'
    end

    context 'ログインしていない場合' do
      it 'はPixivにログインする' do
        expect( book ).to receive(:login)
        subject
      end
    end

    context 'ログインしている場合' do
      it 'はPixivにログインしない' do
        book.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'

        expect( book ).to_not receive(:login)
        subject
      end
    end
  end

  describe '#login' do
    subject{ book.__send__ :login }

    it 'はPixivにログインする' do
      response = double('Response')
      expect( response ).to receive(:[]).with('set-cookie').and_return('PHPSESSID=123456_0123456789abcdef0123456789abcdef; expires=Sun, 02-Mar-2014 00:22:10 GMT; Max-Age=3600; path=/; domain=.pixiv.net, p_ab_id=3; expires=Fri, 01-Jan-2019 00:00:00 GMT; Max-Age=157766400; path=/; domain=.pixiv.net')
      expect( book ).to receive(:post).with(URI('https://www.secure.pixiv.net/login.php'), 'mode=login&pixiv_id=pixiv_id&pass=password').and_return(response)

      subject

      expect( book.instance_variable_get :@session ).to eql '123456_0123456789abcdef0123456789abcdef'
    end

    context 'パスワードが設定されていない場合' do
      let(:book){ described_class.new '12345678', pixiv_id: 'pixiv_id' }

      it 'はPixivにログインしない' do
        expect( book ).to_not receive(:post)

        subject
      end
    end

    context 'Pixiv IDが設定されていない場合' do
      let(:book){ described_class.new '12345678', password: 'password' }

      it 'はPixivにログインしない' do
        expect( book ).to_not receive(:post)

        subject
      end
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
      expect( book ).to receive(:write).with(save_file_path, URI('http://i2.pixiv.net/img999/img/member_nick_id/11111111.png'), {
        'Referer' => 'http://iphone.pxv.jp/',
        'Cookie' => 'PHPSESSID=0123456789abcdef0123456789abcdef',
      })
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
