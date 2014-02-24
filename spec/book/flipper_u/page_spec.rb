# coding: utf-8

require_relative '../../spec_helper.rb'
require 'rubygems'
require 'rmagick'

describe EBookloader::Book::FlipperU::Page do
  let(:options){ { scale: 2, width: 3, height: 4, extension: :jpg } }
  let(:page){ described_class.new 'http://example.com/dir/page1/page.xml', options }
  let(:save_dir){ Pathname('dirname') }

  describe '#save' do
    subject{ page.save 1, save_dir }

    it 'は枚数分#writeを実行して結合する' do
      i = 1
      (1..4).each do |y|
        (1..3).each do |x|
          expect( page ).to receive(:write).with(Pathname("dirname/1_#{x}_#{y}.tmp"), URI("http://example.com/dir/page1/x2/#{i}.jpg"), options)
          i += 1
        end
      end

      expect( page ).to receive(:join).with(Pathname('dirname/1_0_1.tmp'), false, Pathname('dirname/1_1_1.tmp'), Pathname('dirname/1_2_1.tmp'), Pathname('dirname/1_3_1.tmp'))
      expect( page ).to receive(:join).with(Pathname('dirname/1_0_2.tmp'), false, Pathname('dirname/1_1_2.tmp'), Pathname('dirname/1_2_2.tmp'), Pathname('dirname/1_3_2.tmp'))
      expect( page ).to receive(:join).with(Pathname('dirname/1_0_3.tmp'), false, Pathname('dirname/1_1_3.tmp'), Pathname('dirname/1_2_3.tmp'), Pathname('dirname/1_3_3.tmp'))
      expect( page ).to receive(:join).with(Pathname('dirname/1_0_4.tmp'), false, Pathname('dirname/1_1_4.tmp'), Pathname('dirname/1_2_4.tmp'), Pathname('dirname/1_3_4.tmp'))
      expect( page ).to receive(:join).with(Pathname('dirname/1.jpg'), true, Pathname('dirname/1_0_1.tmp'), Pathname('dirname/1_0_2.tmp'), Pathname('dirname/1_0_3.tmp'), Pathname('dirname/1_0_4.tmp'))
      expect( page ).to receive(:filename).with(1).and_return('1.jpg')

      subject
    end
  end

  describe '#join' do
    subject{ page.join Pathname('output'), true, path1, path2, path3 }

    let(:path1){ Pathname('1') }
    let(:path2){ Pathname('2') }
    let(:path3){ Pathname('3') }
    let(:imagelist){ double('Magick::ImageList') }
    let(:imagelist2){ double('Magick::ImageList') }
    before{
      allow( Magick::ImageList ).to receive(:new).with(path1, path2, path3).and_return(imagelist)
      allow( imagelist ).to receive(:append).with(true).and_return( imagelist2 )
      allow( imagelist2 ).to receive(:write).with(Pathname('output'))

      allow( path1 ).to receive(:delete)
      allow( path2 ).to receive(:delete)
      allow( path3 ).to receive(:delete)
    }

    it 'は結合する' do
      expect( Magick::ImageList ).to receive(:new).with(path1, path2, path3).and_return(imagelist)
      expect( imagelist ).to receive(:append).with(true).and_return( imagelist2 )
      expect( imagelist2 ).to receive(:write).with(Pathname('output'))

      subject
    end

    it 'は元ファイルを削除する' do
      expect( path1 ).to receive(:delete).once
      expect( path2 ).to receive(:delete).once
      expect( path3 ).to receive(:delete).once

      subject
    end
  end
end
