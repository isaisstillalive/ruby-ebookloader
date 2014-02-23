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
        it_behaves_like 'a Site#lazy_load @title'

        subject{ site.__send__ :lazy_load }

        before{
            allow( site ).to receive(:get).and_return(responce('/site/gangan_online/identifier.html'))
            site.instance_variable_set :@loaded, true
        }

        it 'はhtmlを取得する' do
            expect( site ).to receive(:get).with(URI('http://www.ganganonline.com/comic/identifier/')).and_return(responce('/site/gangan_online/identifier.html'))
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
    end
end
