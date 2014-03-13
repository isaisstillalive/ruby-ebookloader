# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Togetter do
  let(:book){ described_class.new 'http://togetter.com/li/identifier' }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }
    before{ book.instance_variable_set :@loaded, true }

    it_behaves_like 'a BookInfo updater', title: 'name'

    before{
      allow( book ).to receive(:get).and_return(response('/book/togetter/identifier.html'))
    }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://togetter.com/li/identifier')).and_return(response('/book/togetter/identifier.html')).ordered
      allow( book ).to receive(:get).with(URI('http://togetter.com/api/moreTweets/identifier?page=1&csrf_token=csrf_token')).and_return(response('/book/togetter/api.html')).ordered
      expect( subject ).to eql true
    end

    it 'はcsrf_tokenを使用してmoreTweetsAPIの結果を取得する' do
      expect( book ).to receive(:get).with(URI('http://togetter.com/li/identifier')).and_return(response('/book/togetter/identifier.html')).ordered
      expect( book ).to receive(:get).with(URI('http://togetter.com/api/moreTweets/identifier?page=1&csrf_token=csrf_token')).and_return(response('/book/togetter/api.html')).ordered
      subject
    end

    context do
      before{
        allow( book ).to receive(:get).and_return(response('/book/togetter/identifier.html')).ordered
        allow( book ).to receive(:get).with(URI('http://togetter.com/api/moreTweets/identifier?page=1&csrf_token=csrf_token')).and_return(response('/book/togetter/api.html')).ordered
      }

      it 'は@pagesを設定する' do
        subject

        expect( book.pages ).to eq [
          EBookloader::Book::Page.new(URI('http://pbs.twimg.com/media/Bf3d3CuCIAAdw-K.png:large'), page: 1, extension: :png),
        ]
      end
    end
  end
end
