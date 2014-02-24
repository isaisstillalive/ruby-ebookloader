# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Direct do
    let(:book){ described_class.new 'http://example.com/file.jpg' }

    describe '#lazy_load' do
        subject{ book.__send__ :lazy_load }

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
                expect( book.name ).to eql 'file.jpg'
            end
        end
    end

    describe '#save_core' do
        subject{ book.__send__ :save_core, Pathname('/path/') }

        it 'はファイルを読み込んで保存する' do
            expect( book ).to receive(:write).with(Pathname('/path/file.jpg'), URI('http://example.com/file.jpg'))
            subject
        end
    end
end
