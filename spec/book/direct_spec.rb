# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Direct do
  let(:book){ described_class.new 'http://example.com/file.jpg', option: :option }
  let(:bookinfo){ book }

  describe '#lazy_load' do
    subject{ book.__send__ :lazy_load }

    it_behaves_like 'a BookInfo updater', title: 'file'

    it 'は@pageを設定する' do
      subject

      expect( book.page ).to eq EBookloader::Book::Page.new(URI('http://example.com/file.jpg'), name: 'file', extension: :jpg, option: :option)
    end
  end
end
