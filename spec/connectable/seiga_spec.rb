# coding: utf-8

require_relative '../spec_helper.rb'
require 'csv'

describe EBookloader::Connectable::Seiga do
  class ConnectableObjectSeiga
    include EBookloader::Connectable::Seiga

    def initialize options = {}
      @options = options
    end
  end

  let(:connectable_object){ ConnectableObjectSeiga.new login_id: 'login_id', password: 'password' }
  let(:faraday) { double 'faraday' }
  let(:conn){ double 'conn' }

  describe '#run_request' do
    subject{ connectable_object.__send__ :run_request, :method, uri }
    let(:uri){ URI('http://example.com/path') }
    let(:conn){ double('FaradayConnector') }
    before{
      allow( connectable_object ).to receive(:login)
      allow( connectable_object ).to receive(:conn).and_return(conn)
      allow( conn ).to receive(:run_request).and_return(double('Response', body: ''))
    }

    it 'はセッションCookieを渡してFaradayにアクセスする' do
      connectable_object.instance_variable_set :@session, 'user_session_123456_0123456789abcdef0123456789abcdef'
      expect( conn ).to receive(:run_request).with(:method, anything(), anything(), {
        'Cookie' => 'user_session=user_session_123456_0123456789abcdef0123456789abcdef',
      })
      subject
    end

    it 'はレスポンスボディのエンコーディングをUTF8に変更する' do
      connectable_object.instance_variable_set :@session, 'user_session_123456_0123456789abcdef0123456789abcdef'
      body = 'abcde'
      body.force_encoding Encoding::ASCII
      allow( conn ).to receive(:run_request).with(:method, anything(), anything(), anything()).and_return(double('Response', body: body))
      expect( subject.body.encoding ).to eql Encoding::UTF_8
    end

    context 'ヘッダが渡されている場合' do
      subject{ connectable_object.__send__ :run_request, :method, uri, nil, {header: :header} }

      it 'はFaradayにヘッダを渡す' do
        connectable_object.instance_variable_set :@session, 'user_session_123456_0123456789abcdef0123456789abcdef'
        expect( conn ).to receive(:run_request).with(:method, anything(), anything(), {
          'Cookie' => 'user_session=user_session_123456_0123456789abcdef0123456789abcdef',
          :header => :header,
        })
        subject
      end
    end

    context 'ヘッダがnilの場合' do
      subject{ connectable_object.__send__ :run_request, :method, uri, nil, nil }

      it 'はハッシュに変換する' do
        connectable_object.instance_variable_set :@session, 'user_session_123456_0123456789abcdef0123456789abcdef'
        expect( conn ).to receive(:run_request).with(:method, anything(), anything(), {
          'Cookie' => 'user_session=user_session_123456_0123456789abcdef0123456789abcdef',
        })
        subject
      end
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
    let(:response){ double('Response', body: '') }

    before{
      allow( response ).to receive(:[]).with('set-cookie').and_return('Set-Cookie: user_session=user_session_123456_0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef; expires=Tue, 08-Apr-2014 12:53:55 GMT; path=/; domain=.nicovideo.jp')
      allow( connectable_object ).to receive(:conn).and_return(conn)
      allow( conn ).to receive(:run_request).and_return(response)
    }

    it 'はPixivにログインする' do
      expect( connectable_object ).to receive(:post).with(URI('https://secure.nicovideo.jp/secure/login?site=seiga'), 'mail=login_id&password=password').and_return(response)

      subject

      expect( connectable_object.instance_variable_get :@session ).to eql 'user_session_123456_0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
    end

    context '未ログインの場合' do
      it 'はセッションIDを取得しようとして無限ループしない' do
        expect( connectable_object ).to receive(:post).with(URI('https://secure.nicovideo.jp/secure/login?site=seiga'), 'mail=login_id&password=password').and_call_original.once

        subject
      end
    end

    context 'パスワードが設定されていない場合' do
      let(:connectable_object){ ConnectableObjectSeiga.new login_id: 'login_id' }

      it 'はPixivにログインしない' do
        expect( connectable_object ).to_not receive(:post)

        subject
      end
    end

    context 'Pixiv IDが設定されていない場合' do
      let(:connectable_object){ ConnectableObjectSeiga.new password: 'password' }

      it 'はPixivにログインしない' do
        expect( connectable_object ).to_not receive(:post)

        subject
      end
    end
  end
end
