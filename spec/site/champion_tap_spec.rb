# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::ChampionTap do
    let(:site){ described_class.new 'identifier' }

    describe '#uri' do
        subject{ site.uri }

        it 'はサイトのURIを取得する' do
            expect( subject ).to eql URI('http://tap.akitashoten.co.jp/comics/identifier/')
        end
    end

    describe '#lazy_load' do
        subject{ site.__send__ :lazy_load }

        before{
            allow( site ).to receive(:get).and_return(responce('/site/champion_tap/identifier.html'))
        }

        it 'はhtmlを取得する' do
            expect( site ).to receive(:get).with(URI('http://tap.akitashoten.co.jp/comics/identifier/')).and_return(responce('/site/champion_tap/identifier.html'))
            expect( subject ).to eql true
        end

        it 'は@booksを設定する' do
            subject

            # expect( site.books.size ).to eql 4
            expect( site.books.to_a ).to eq [
                EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/4'),
                EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/3'),
                EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/2'),
                EBookloader::Book::AkitashotenReadingCommunicator.new('http://tap.akitashoten.co.jp/comics/identifier/1'),
            ]
            expect( site.books.map{ |book| book.name }.to_a ).to eql [
                '[author] title ep4 episode4',
                '[author] title ep3 episode3',
                '[author] title ep2 episode2',
                '[author] title ep1 episode1',
            ]
        end

        context '@nameが設定されている場合' do
            before{ site.name = 'old_name' }

            it 'は@nameを設定しない' do
                subject
                expect( site.name ).to eql 'old_name'
            end
        end

        context '@nameが設定されていない場合' do
            it 'は@nameを設定する' do
                subject
                expect( site.name ).to eql '[author] title'
            end
        end
    end
end
