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
    subject{ book.__send__ :save_core, Pathname('/path/') }

    it 'はファイルを読み込んで保存する' do
      expect( book ).to receive(:write).with(Pathname('/path/file.jpg'), URI('http://example.com/file.jpg'))
      subject
    end
  end
end
