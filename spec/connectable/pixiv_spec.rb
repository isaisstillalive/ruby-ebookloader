# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Connectable::Pixiv do
  class ConnectableObjectPixiv
    include EBookloader::Connectable::Pixiv

    def initialize options = {}
      @options = options
    end
  end

  let(:connectable_object){ ConnectableObjectPixiv.new pixiv_id: 'pixiv_id', password: 'password' }
  let(:faraday) { double 'faraday' }
  let(:conn){ double 'conn' }

  describe '#run_request' do
    subject{ connectable_object.__send__ :run_request, :method, uri }
    let(:uri){ URI('http://example.com/path') }
    let(:conn){ double('FaradayConnector') }
    before{
      allow( connectable_object ).to receive(:login)
      allow( connectable_object ).to receive(:conn).and_return(conn)
      allow( conn ).to receive(:run_request)
    }

    it 'はリファラとセッションCookieを渡してFaradayにアクセスする' do
      connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
      expect( conn ).to receive(:run_request).with(:method, anything(), anything(), {
        'Referer' => 'http://iphone.pxv.jp/',
        'Cookie' => 'PHPSESSID=0123456789abcdef0123456789abcdef',
      })
      subject
    end

    it 'はURIにSESSIONIDを渡してFaradayにアクセスする' do
      connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
      expect( conn ).to receive(:run_request).with(:method, '/path?&PHPSESSID=0123456789abcdef0123456789abcdef', anything(), anything())
      subject
    end

    context 'ボディが渡されている場合' do
      subject{ connectable_object.__send__ :run_request, :method, uri, :body, nil }

      it 'はFaradayにボディを渡す' do
        connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
        expect( conn ).to receive(:run_request).with(:method, anything(), :body, anything())
        subject
      end
    end

    context 'ヘッダが渡されている場合' do
      subject{ connectable_object.__send__ :run_request, :method, uri, nil, {header: :header} }

      it 'はFaradayにヘッダを渡す' do
        connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
        expect( conn ).to receive(:run_request).with(:method, anything(), anything(), {
          'Referer' => 'http://iphone.pxv.jp/',
          'Cookie' => 'PHPSESSID=0123456789abcdef0123456789abcdef',
          :header => :header,
        })
        subject
      end
    end

    context 'ヘッダがnilの場合' do
      subject{ connectable_object.__send__ :run_request, :method, uri, nil, nil }

      it 'はハッシュに変換する' do
        connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'
        expect( conn ).to receive(:run_request).with(:method, anything(), anything(), {
          'Referer' => 'http://iphone.pxv.jp/',
          'Cookie' => 'PHPSESSID=0123456789abcdef0123456789abcdef',
        })
        subject
      end
    end
  end

  describe '#get_csv' do
    subject{ connectable_object.__send__ :get_csv, URI('http://example.com/') }

    it 'はPixivにアクセスしてCSVを取得する' do
      expect( connectable_object ).to receive(:get).with(URI('http://example.com/')).and_return(response('/book/pixiv/illust.csv'))

      expect( subject ).to eq [[
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
      ]]
    end
  end

  describe '#get_illust_csv' do
    subject{ connectable_object.__send__ :get_illust_csv, '12345678' }
    let(:result){ double('CSV Result') }

    it 'はPixivにアクセスしてCSVを取得する' do
      expect( connectable_object ).to receive(:get_csv).with(URI('http://spapi.pixiv.net/iphone/illust.php?illust_id=12345678')).and_return([result])

      expect( subject ).to eql result
    end
  end

  describe '#get_member_illist_csv' do
    subject{ connectable_object.__send__ :get_member_illist_csv, '12345678' }
    let(:result){ double('CSV Result') }

    it 'はPixivにアクセスしてCSVを取得する' do
      expect( connectable_object ).to receive(:get_csv).with(URI('http://spapi.pixiv.net/iphone/member_illust.php?id=12345678')).and_return(result)

      expect( subject ).to eql result
    end
  end

  describe '#get_member' do
    subject{ connectable_object.__send__ :get_member, '12345678' }
    let(:result){ double('CSV Result') }

    it 'はPixivにアクセスしてCSVを取得する' do
      expect( connectable_object ).to receive(:get).with(URI('http://spapi.pixiv.net/iphone/profile.php?id=12345678')).and_return(result)

      expect( subject ).to eql result
    end
  end

  describe '#session' do
    subject{ connectable_object.__send__ :session }

    it 'はセッションIDを返す' do
      connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'

      expect( subject ).to eql '0123456789abcdef0123456789abcdef'
    end

    context 'ログインしていない場合' do
      it 'はPixivにログインする' do
        expect( connectable_object ).to receive(:login)
        subject
      end
    end

    context 'ログインしている場合' do
      it 'はPixivにログインしない' do
        connectable_object.instance_variable_set :@session, '0123456789abcdef0123456789abcdef'

        expect( connectable_object ).to_not receive(:login)
        subject
      end
    end
  end

  describe '#login' do
    subject{ connectable_object.__send__ :login }
    let(:conn){ double('FaradayConnector') }
    let(:response){ double('Response') }

    before{
      allow( response ).to receive(:[]).with('set-cookie').and_return('PHPSESSID=123456_0123456789abcdef0123456789abcdef; expires=Sun, 02-Mar-2014 00:22:10 GMT; Max-Age=3600; path=/; domain=.pixiv.net, p_ab_id=3; expires=Fri, 01-Jan-2019 00:00:00 GMT; Max-Age=157766400; path=/; domain=.pixiv.net')
      allow( connectable_object ).to receive(:conn).and_return(conn)
      allow( conn ).to receive(:run_request).and_return(response)
    }

    it 'はPixivにログインする' do
      expect( connectable_object ).to receive(:post).with(URI('https://www.secure.pixiv.net/login.php'), 'mode=login&pixiv_id=pixiv_id&pass=password').and_return(response)

      subject

      expect( connectable_object.instance_variable_get :@session ).to eql '123456_0123456789abcdef0123456789abcdef'
    end

    context '未ログインの場合' do
      it 'はセッションIDを取得しようとして無限ループしない' do
        expect( connectable_object ).to receive(:post).with(URI('https://www.secure.pixiv.net/login.php'), 'mode=login&pixiv_id=pixiv_id&pass=password').and_call_original.once

        subject
      end
    end

    context 'パスワードが設定されていない場合' do
      let(:connectable_object){ ConnectableObjectPixiv.new pixiv_id: 'pixiv_id' }

      it 'はPixivにログインしない' do
        expect( connectable_object ).to_not receive(:post)

        subject
      end
    end

    context 'Pixiv IDが設定されていない場合' do
      let(:connectable_object){ ConnectableObjectPixiv.new password: 'password' }

      it 'はPixivにログインしない' do
        expect( connectable_object ).to_not receive(:post)

        subject
      end
    end
  end
end
