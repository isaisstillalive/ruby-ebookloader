# coding: utf-8

require_relative '../../spec_helper.rb'

describe EBookloader::Book::MultiplePages::Page do
    describe '#uri' do
        let(:page){ described_class.new 'uri' }
        subject{ page.uri }

        it 'はURIを返す' do
            expect( subject ).to eql URI('uri')
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
        subject{ page1 == page2 }

        context '@uriと名前と拡張子が同じ場合' do
            let(:page1){ described_class.new 'uri', extension: :extension, name: 'name' }
            let(:page2){ described_class.new 'uri', extension: :extension, name: 'name' }

            it 'はtrueを返す' do
                expect( subject ).to eql true
            end
        end
        
        context '@uriが異なる場合' do
            let(:page1){ described_class.new 'uri1', extension: :extension, name: 'name' }
            let(:page2){ described_class.new 'uri2', extension: :extension, name: 'name' }

            it 'はfalseを返す' do
                expect( subject ).to eql false
            end
        end
        
        context '拡張子が異なる場合' do
            let(:page1){ described_class.new 'uri', extension: :extension1, name: 'name' }
            let(:page2){ described_class.new 'uri', extension: :extension2, name: 'name' }

            it 'はfalseを返す' do
                expect( subject ).to eql false
            end
        end
        
        context '名前が異なる場合' do
            let(:page1){ described_class.new 'uri', extension: :extension, name: 'name1' }
            let(:page2){ described_class.new 'uri', extension: :extension, name: 'name2' }

            it 'はfalseを返す' do
                expect( subject ).to eql false
            end
        end
    end
end
