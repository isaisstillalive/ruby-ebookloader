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
      expect( page ).to receive(:sliced_files).with(4, save_dir, '1_0_%d.tmp').and_return([Pathname('dirname/1_0_1.tmp'), Pathname('dirname/1_0_2.tmp')])
      expect( page ).to receive(:sliced_files).with(3, save_dir, '1_%d_1.tmp').and_return([Pathname('dirname/1_1_1.tmp'), Pathname('dirname/1_2_1.tmp')])
      expect( page ).to receive(:sliced_files).with(3, save_dir, '1_%d_2.tmp').and_return([Pathname('dirname/1_1_2.tmp'), Pathname('dirname/1_2_2.tmp')])
      expect( page ).to receive(:write).with(Pathname("dirname/1_1_1.tmp"), URI("http://example.com/dir/page1/x2/1.jpg"), options)
      expect( page ).to receive(:write).with(Pathname("dirname/1_2_1.tmp"), URI("http://example.com/dir/page1/x2/2.jpg"), options)
      expect( page ).to receive(:write).with(Pathname("dirname/1_1_2.tmp"), URI("http://example.com/dir/page1/x2/3.jpg"), options)
      expect( page ).to receive(:write).with(Pathname("dirname/1_2_2.tmp"), URI("http://example.com/dir/page1/x2/4.jpg"), options)
      expect( page ).to receive(:join).with(Pathname('dirname/1_0_1.tmp'), [Pathname('dirname/1_1_1.tmp'), Pathname('dirname/1_2_1.tmp')], false)
      expect( page ).to receive(:join).with(Pathname('dirname/1_0_2.tmp'), [Pathname('dirname/1_1_2.tmp'), Pathname('dirname/1_2_2.tmp')], false)
      expect( page ).to receive(:join).with(Pathname('dirname/1.jpg'), [Pathname('dirname/1_0_1.tmp'), Pathname('dirname/1_0_2.tmp')], true)
      expect( page ).to receive(:filename).with(1).and_return('1.jpg')

      subject
    end
  end

  describe '#join' do
    subject{ page.__send__ :join, Pathname('output'), [path1, path2, path3], true }

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

  describe '#sliced_files' do
    subject{ page.__send__ :sliced_files, 3, Pathname('dirname'), "file_%d.tmp" }

    it 'はファイル名テンプレートをcount数繰り返した配列を返す' do
      expect( subject ).to eql [
        Pathname('dirname/file_1.tmp'),
        Pathname('dirname/file_2.tmp'),
        Pathname('dirname/file_3.tmp'),
      ]
    end
  end
end
