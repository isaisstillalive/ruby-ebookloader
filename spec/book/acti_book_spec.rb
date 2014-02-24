# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::ActiBook do
    let(:book){ described_class.new 'http://example.com/dir/_SWF_Window.html' }

    describe '#lazy_load' do
        subject{ book.__send__ :lazy_load }

        before{
            allow( book ).to receive(:get).and_return(responce('/book/acti_book/book.xml'))
        }

        it 'はbook.xmlを取得する' do
            expect( book ).to receive(:get).with(URI('http://example.com/dir/books/db/book.xml')).and_return(responce('/book/acti_book/book.xml'))
            expect( subject ).to eql true
        end

        it 'は@pagesを設定する' do
            subject

            expect( book.pages.size ).to eql 2
            expect( book.pages.to_a ).to eq [
                URI('http://example.com/dir/books/images/2/1.jpg'),
                URI('http://example.com/dir/books/images/2/2.jpg'),
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
                expect( book.name ).to eql 'name'
            end
        end
    end
end
