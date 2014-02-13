# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::AkitashotenReadingCommunicator do
    let(:book){ described_class.new 'http://tap.akitashoten.co.jp/comics/identifier/1' }

    describe '#lazy_load' do
        subject{ book.__send__ :lazy_load }

        before{
            allow( book ).to receive(:get).and_return( double('responce', {:body => IO.readlines(File.dirname(__FILE__) + '/fixtures/akitashoten_reading_communicator/1.html', nil).first}) )
        }

        it 'はhtmlを取得する' do
            expect( book ).to receive(:get).with(URI('http://tap.akitashoten.co.jp/comics/identifier/1')).and_return( double('responce', {:body => IO.readlines(File.dirname(__FILE__) + '/fixtures/akitashoten_reading_communicator/1.html', nil).first}) )
            expect( subject ).to eql true
        end

        it 'は@pagesを設定する' do
            subject

            expect( book.pages.to_a ).to eql [
                ['001.jpg', URI('http://tap.akitashoten.co.jp/comics/identifier/1/1')],
                ['002.jpg', URI('http://tap.akitashoten.co.jp/comics/identifier/1/2')],
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
