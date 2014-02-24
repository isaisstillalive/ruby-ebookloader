# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Togetter do
  let(:book){ described_class.new 'http://togetter.com/li/identifier' }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it 'はhtmlを取得する' do
      expect( book ).to receive(:get).with(URI('http://togetter.com/li/identifier')).and_return(responce('/book/togetter/identifier.html')).ordered
      allow( book ).to receive(:get).with(URI('http://togetter.com/api/moreTweets/identifier?page=1&csrf_token=csrf_token')).and_return(responce('/book/togetter/api.html')).ordered
      expect( subject ).to eql true
    end

    it 'はcsrf_tokenを使用してmoreTweetsAPIの結果を取得する' do
      expect( book ).to receive(:get).with(URI('http://togetter.com/li/identifier')).and_return(responce('/book/togetter/identifier.html')).ordered
      expect( book ).to receive(:get).with(URI('http://togetter.com/api/moreTweets/identifier?page=1&csrf_token=csrf_token')).and_return(responce('/book/togetter/api.html')).ordered
      subject
    end

    context do
      before{
        allow( book ).to receive(:get).and_return(responce('/book/togetter/identifier.html')).ordered
        allow( book ).to receive(:get).with(URI('http://togetter.com/api/moreTweets/identifier?page=1&csrf_token=csrf_token')).and_return(responce('/book/togetter/api.html')).ordered
      }

      it 'は@pagesを設定する' do
        subject

        # expect( book.pages.size ).to eql 2
        expect( book.pages.to_a ).to eq [
          EBookloader::Book::MultiplePages::Page.new(URI('http://pbs.twimg.com/media/Bf3d3CuCIAAdw-K.png:large'), extension: :png),
        ]
      end

      context '@nameが設定されている場合' do
        before{ book.name = 'old_name' }

        it 'は@nameを設定しない' do
          subject
          expect( book.name ).to eql 'old_name'
        end
      end

      context '@nameが設定されていない場合' do
        it 'は@nameを設定する' do
          subject
          expect( book.name ).to eql 'name'
        end
      end
    end
  end
end
