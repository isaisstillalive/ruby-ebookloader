# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Site do
    let(:book){ described_class.new 'uri' }

    describe '#uri' do
        subject{ book.uri }

        it 'は@uriを返す' do
            expect( subject ).to eql URI('uri')
        end
    end

    describe '#name' do
        subject{ book.name }

        context '@nameが設定されている場合' do
            before{ book.name = 'name' }

            it 'は@nameを返す' do
                expect( subject ).to eql 'name'
            end
        end

        context '@nameが設定されていない場合' do
            it 'は#lazy_loadを実行し、@nameを返す' do
                def book.lazy_load
                    @name = 'name'
                    true
                end
                expect( book ).to receive(:lazy_load).and_call_original
                expect( subject ).to eql 'name'
            end
        end
    end

    describe '#books' do
        subject{ book.books }

        it 'は#lazy_loadを実行し、@booksを返す' do
            def book.lazy_load
                @books = ['books']
                true
            end
            expect( book ).to receive(:lazy_load).and_call_original
            expect( subject ).to eql ['books']
        end
    end
end
