# coding: utf-8

require_relative '../../spec_helper.rb'

describe EBookloader::Book::Direct::Multiple do
  let(:book){ described_class.new 'http://example.com/dir/file[1-3].jpg', option: :option }

  describe '#lazy_load' do
    let(:bookinfo){ book }
    subject{ book.__send__ :lazy_load }

    it 'は@pagesを設定する' do
      subject

      expect( book.pages ).to eq [
        EBookloader::Book::Page.new(URI('http://example.com/dir/file1.jpg'), page: 1, option: :option),
        EBookloader::Book::Page.new(URI('http://example.com/dir/file2.jpg'), page: 2, option: :option),
        EBookloader::Book::Page.new(URI('http://example.com/dir/file3.jpg'), page: 3, option: :option),
      ]
    end

    context 'nameオプションが設定されている場合' do
      let(:book){ described_class.new 'http://example.com/dir/file[1-2]{_a,_b}.jpg', name: 'name#1#2', option: :option }

      it 'はページ名を@pagesに設定する' do
        subject

        expect( book.pages ).to eq [
          EBookloader::Book::Page.new(URI('http://example.com/dir/file1_a.jpg'), name: 'name1_a', page: 1, option: :option),
          EBookloader::Book::Page.new(URI('http://example.com/dir/file1_b.jpg'), name: 'name1_b', page: 2, option: :option),
          EBookloader::Book::Page.new(URI('http://example.com/dir/file2_a.jpg'), name: 'name2_a', page: 3, option: :option),
          EBookloader::Book::Page.new(URI('http://example.com/dir/file2_b.jpg'), name: 'name2_b', page: 4, option: :option),
        ]
      end
    end
  end
end
