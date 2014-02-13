# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::Book do
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

    describe '#save' do
        let(:dir_path){ Pathname('dir') }
        subject{ book.save 'dir' }
        before{
            allow_any_instance_of( Kernel ).to receive(:Pathname).and_return(dir_path)
            allow( dir_path ).to receive(:mkdir)
        }

        it 'は#save_coreを実行し戻り値を返す' do
            expect_any_instance_of( Kernel ).to receive(:Pathname).with('dir').and_return(dir_path)
            expect( book ).to receive(:save_core).with(dir_path).and_return(true)
            expect( subject ).to eql true
        end
        
        context '引数のディレクトリが存在する場合' do
            it 'はディレクトリを作成しない' do
                expect( dir_path ).to receive(:exist?).and_return(true)
                expect( dir_path ).to_not receive(:mkdir)
                subject
            end
        end

        context '引数のディレクトリが存在しない場合' do
            it 'はディレクトリを作成する' do
                expect( dir_path ).to receive(:exist?).and_return(false)
                expect( dir_path ).to receive(:mkdir)
                subject
            end
        end
    end

    describe '#write' do
        let(:file_path){ Pathname('dir') }
        let(:file_pointer){ double(:file_pointer) }
        subject{ book.__send__ :write, file_path, URI('uri') }

        it 'は#getを実行した結果をファイルに書き込む' do
            expect( file_path ).to receive(:open).with('wb').and_yield(file_pointer)
            expect( book ).to receive(:get).with(URI('uri')).and_return( double('responce', {:body => 'body'}) )
            expect( file_pointer ).to receive(:write).with('body')
            subject
        end
    end
end
