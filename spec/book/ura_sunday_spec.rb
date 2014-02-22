# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::UraSunday do
    let(:book){ described_class.new 'http://urasunday.com/identifier/comic/001_001.html' }

    describe '#lazy_load' do
        subject{ book.__send__ :lazy_load }

        it 'はhtmlを取得する' do
            expect( book ).to receive(:get).with(URI('http://urasunday.com/identifier/comic/001_001.html')).and_return(responce('/book/ura_sunday/001_001.html'))
            expect( subject ).to eql true
        end

        context '画像直指定の場合' do
            before{
                allow( book ).to receive(:get).and_return(responce('/book/ura_sunday/001_001.html'))
            }

            it 'は@pagesを設定する' do
                subject

                expect( book.pages.size ).to eql 2
                expect( book.pages.to_a ).to eq [
                    URI('http://urasunday.com/comic/identifier/pc/001/001_001_01.jpg'),
                    URI('http://urasunday.com/comic/identifier/pc/001/001_001_02.jpg'),
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
                    expect( book.name ).to eql '[author] title episode'
                end
            end
        end

        context '画像埋め込みの場合' do
            before{
                allow( book ).to receive(:get).and_return(responce('/book/ura_sunday/002_002.html'))
            }

            it 'は@pagesを設定する' do
                subject

                expect( book.pages.size ).to eql 2
                expect( book.pages.to_a ).to eq [
                    URI('http://img.urasunday.com/eximages/comic/identifier/pc/002/002_002_01.jpg'),
                    URI('http://img.urasunday.com/eximages/comic/identifier/pc/002/002_002_02.jpg'),
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
                    expect( book.name ).to eql '[author] title episode'
                end
            end
        end
    end
end
