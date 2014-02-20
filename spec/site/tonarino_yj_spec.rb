# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::TonarinoYJ do
    let(:site){ described_class.new 'identifier' }

    describe '#uri' do
        subject{ site.uri }

        it 'はサイトのURIを取得する' do
            expect( subject ).to eql URI('http://tonarinoyj.jp/manga/identifier/')
        end
    end

    describe '#lazy_load' do
        subject{ site.__send__ :lazy_load }

        before{
            allow( site ).to receive(:get).and_return(responce('/site/tonarino_yj/identifier.html'))
        }

        it 'はhtmlを取得する' do
            expect( site ).to receive(:get).with(URI('http://tonarinoyj.jp/manga/identifier/')).and_return(responce('/site/tonarino_yj/identifier.html'))
            expect( subject ).to eql true
        end

        it 'は@booksを設定する' do
            subject

            # expect( site.books.size ).to eql 2
            expect( site.books.to_a ).to eq [
                EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/1/'),
                EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/1_5/'),
                EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/2/?viewer=vertical'),
                EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/extra-1/'),
                EBookloader::Book::Aoharu.new('http://tonarinoyj.jp/manga/identifier/extra-2/'),
            ]
            expect( site.books.map{ |book| book.name }.to_a ).to eql [
                '[author] title episode1',
                '[author] title episode1.5',
                '[author] title episode2',
                '[author] title extra_episode1',
                '[author] title extra_episode2',
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

    describe '#convert_author' do
        subject{ site.__send__ :convert_author, author }

        context '原案付きの場合' do
            let(:author){ '漫画：author1<br />原案：author2' }

            it 'は並列表記する' do
                expect( subject ).to eql 'author1, author2'
            end
        end

        context '作画・原作別の場合' do
            let(:author){ '原作/author1　作画/author2' }

            it 'は並列表記する' do
                expect( subject ).to eql 'author1, author2'
            end
        end
    end
end
