# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Site::GanganOnline do
    let(:site){ described_class.new 'identifier' }

    describe '#uri' do
        subject{ site.uri }

        it 'はサイトのURIを取得する' do
            expect( subject ).to eql URI('http://www.ganganonline.com/comic/identifier/')
        end
    end

    describe '#lazy_load' do
        subject{ site.__send__ :lazy_load }

        before{
            allow( site ).to receive(:get).and_return( double('responce', {:body => IO.readlines(File.dirname(__FILE__) + '/fixtures/gangan_online/identifier.html', nil).first}) )
        }

        it 'はhtmlを取得する' do
            expect( site ).to receive(:get).with(URI('http://www.ganganonline.com/comic/identifier/')).and_return( double('responce', {:body => IO.readlines(File.dirname(__FILE__) + '/fixtures/gangan_online/identifier.html', nil).first}) )
            expect( subject ).to eql true
        end

        it 'は@booksを設定する' do
            subject

            # expect( site.books.size ).to eql 2
            expect( site.books.to_a ).to eq [
                EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/identifier/001/_SWF_Window.html'),
                EBookloader::Book::ActiBook.new('http://www.ganganonline.com/viewer/pc/comic/identifier/002/_SWF_Window.html'),
            ]
            expect( site.books.map{ |book| book.name }.to_a ).to eql [
                'title ep1 episode1',
                'title ep2 episode2',
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
                expect( site.name ).to eql 'title'
            end
        end
    end
end
