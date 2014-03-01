# coding: utf-8

require_relative '../../spec_helper.rb'

describe EBookloader::Book::MultiplePages::Page do
  describe '初期化' do
    let(:options){ { option: :option } }
    subject{ described_class.new 'uri', options }

    it 'はURIを設定する' do
      instance = subject
      expect( instance.uri ).to eql URI('uri')
    end

    it 'はオプションを設定する' do
      instance = subject
      expect( instance.options ).to eql({ option: :option, extension: :jpg })
    end

    it 'は引数で渡されたオプションHashを変更しない' do
      instance = subject
      expect( options ).to eql({ option: :option })
    end
  end

  describe '#uri' do
    let(:page){ described_class.new 'uri' }
    subject{ page.uri }

    it 'はURIを返す' do
      expect( subject ).to eql URI('uri')
    end
  end

  describe '#options' do
    let(:page){ described_class.new 'uri', option: :option }
    subject{ page.options }

    it 'はオプションを返す' do
      expect( subject ).to eql option: :option, extension: :jpg
    end

    it 'は変更不可である' do
      expect( subject.frozen? ).to eql true
    end
  end

  describe '#name' do
    let(:page){ described_class.new 'uri', name: 'name' }
    subject{ page.name }

    it 'は名前を返す' do
      expect( subject ).to eql 'name'
    end

    context '名前が設定されていない場合' do
      let(:page){ described_class.new 'uri' }

      it 'はnilを返す' do
        expect( subject ).to eql nil
      end
    end
  end

  describe '#extension' do
    let(:page){ described_class.new 'uri', extension: :png }
    subject{ page.extension }

    it 'は拡張子を返す' do
      expect( subject ).to eql :png
    end

    context '拡張子が設定されていない場合' do
      let(:page){ described_class.new URI('http://example.com/1.png') }

      it 'はURIの拡張子を返す' do
        expect( subject ).to eql :png
      end

      context 'URIからも拡張子が取得できない場合' do
        let(:page){ described_class.new 'uri' }

        it 'は:jpgを返す' do
          expect( subject ).to eql :jpg
        end
      end
    end
  end

  describe '#filename' do
    subject{ page.filename 1 }

    context '名前が設定されている場合' do
      let(:page){ described_class.new 'uri', name: 'name', extension: :png }

      it 'はページ番号と名前と拡張子を結合して返す' do
        expect( subject ).to eql '001_name.png'
      end
    end

    context '名前が設定されていない場合' do
      let(:page){ described_class.new 'uri', extension: :png }

      it 'はページ番号を3桁にし、拡張子を結合して返す' do
        expect( subject ).to eql '001.png'
      end
    end
  end

  describe '#==' do
    let(:page1){ described_class.new 'uri', extension: :extension, name: 'name', option: :option }
    subject{ page1 == page2 }

    context '@uriと名前と拡張子とオプションが同じ場合' do
      let(:page2){ described_class.new 'uri', extension: :extension, name: 'name', option: :option }

      it 'はtrueを返す' do
        expect( subject ).to eql true
      end
    end

    context 'クラスが異なる場合' do
      class SubPage < described_class
      end
      let(:page2){ SubPage.new 'uri', extension: :extension, name: 'name', option: :option }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context '@uriが異なる場合' do
      let(:page2){ described_class.new 'uri2', extension: :extension, name: 'name', option: :option }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context '拡張子が異なる場合' do
      let(:page2){ described_class.new 'uri', extension: :extension2, name: 'name', option: :option }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context '名前が異なる場合' do
      let(:page2){ described_class.new 'uri', extension: :extension, name: 'name2', option: :option }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end

    context 'オプションが異なる場合' do
      let(:page2){ described_class.new 'uri', extension: :extension, name: 'name', option: :option2 }

      it 'はfalseを返す' do
        expect( subject ).to eql false
      end
    end
  end

  describe '#save' do
    let(:page){ described_class.new 'uri' }
    subject{ page.save 1, Pathname('dirname') }

    it 'は#writeを実行する' do
      expect( page ).to receive(:filename).with(1).and_return('1.jpg')
      expect( page ).to receive(:write).with(Pathname('dirname/1.jpg'), URI('uri'), extension: :jpg)
      subject
    end

    context '保存先パスが文字列の場合' do
      subject{ page.save 1, 'dirname' }

      it 'はPathnameと同様に処理する' do
        expect( page ).to receive(:filename).with(1).and_return('1.jpg')
        expect( page ).to receive(:write).with(Pathname('dirname/1.jpg'), URI('uri'), extension: :jpg)
        subject
      end
    end

    context 'オプションが設定されている場合' do
      let(:page){ described_class.new 'uri', options }
      let(:options){ { headers: {header: :header}, extension: :jpg } }

      it 'は#writeにオプションを渡す' do
        allow( page ).to receive(:filename).with(1).and_return('1.jpg')
        expect( page ).to receive(:write).with(Pathname('dirname/1.jpg'), URI('uri'), options)
        subject
      end
    end
  end
end
