# coding: utf-8

require_relative '../../spec_helper.rb'
require 'rubygems'
require 'rmagick'

describe EBookloader::Book::FlipperU::Page do
  let(:options){ { scale: 2, width: 3, height: 4, extension: :jpg, page: 1 } }
  let(:page){ described_class.new 'http://example.com/dir/page1/page.xml', options }
  let(:save_dir){ Pathname('dirname') }

  describe '#save' do
    subject{ page.save save_dir }

    it 'は枚数分#writeを実行して結合する' do
      h_imagelist = double('Magick::ImageList')
      v_imagelist = double('Magick::ImageList')
      expect( Magick::ImageList ).to receive(:new).and_return(v_imagelist, h_imagelist, h_imagelist, h_imagelist, h_imagelist)

      v_image = double('Magick::ImageList')
      h_image_1 = double('Magick::ImageList')
      h_image_2 = double('Magick::ImageList')
      h_image_3 = double('Magick::ImageList')
      h_image_4 = double('Magick::ImageList')
      expect( h_imagelist ).to receive(:append).with(false).and_return(h_image_1, h_image_2, h_image_3, h_image_4)
      expect( v_imagelist ).to receive(:append).with(true).and_return(v_image)

      expect( v_imagelist ).to receive(:<<).with(h_image_1)
      expect( v_imagelist ).to receive(:<<).with(h_image_2)
      expect( v_imagelist ).to receive(:<<).with(h_image_3)
      expect( v_imagelist ).to receive(:<<).with(h_image_4)

      expect( v_image ).to receive(:write).with(Pathname('dirname/1.jpg'))

      1.upto 12 do |i|
        expect( page ).to receive(:get).with(URI("http://example.com/dir/page1/x2/#{i}.jpg")).and_return(double('response', body: "#{i}"))
        expect( h_imagelist ).to receive(:from_blob).with("#{i}")
      end
      expect( page ).to receive(:filename).with(0).and_return('1.jpg')

      subject
    end
  end
end
