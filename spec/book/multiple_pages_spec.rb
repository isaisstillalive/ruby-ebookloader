# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::MultiplePages do
    let(:book){ Object.new.extend described_class }

    describe '#pages' do
        subject{ book.pages }

        context '@pagesが設定されている場合' do
            before{ book.instance_variable_set(:@pages, ['pages']) }

            it 'は@pagesを返す' do
                expect( subject ).to eql ['pages']
            end
        end

        context '@pagesが設定されていない場合' do
            it 'は#lazy_loadを実行し、@pagesを返す' do
                def book.lazy_load
                    @pages = ['pages']
                    true
                end
                expect( book ).to receive(:lazy_load).and_call_original
                expect( subject ).to eql ['pages']
            end
        end
    end

    describe '#save_core(dirname)' do
        let(:dir_path){ Pathname('dirname') }
        let(:save_dir_path){ Pathname('dirname/name') }
        subject{ book.__send__ :save_core, dir_path }

        before{
            allow( book ).to receive(:name).and_return('name')
            allow( book ).to receive(:pages).and_return([])

            allow( dir_path ).to receive(:+).and_return(save_dir_path)
            allow( save_dir_path ).to receive(:mkdir)
        }

        it 'はtrueを返す' do
            expect( subject ).to eql true
        end

        it 'はdirname/nameを保存ディレクトリとして使用する' do
            expect( book ).to receive(:name).and_return('name')
            expect( dir_path ).to receive(:+).with('name').and_return(save_dir_path)
            subject
        end

        it 'はpagesの数だけ#writeを実行する' do
            expect( book ).to receive(:pages).and_return([['1.jpg', URI('1')], ['2.jpg', URI('2')]])
            expect( book ).to receive(:write).with(Pathname('dirname/name/1.jpg'), URI('1')).ordered
            expect( book ).to receive(:write).with(Pathname('dirname/name/2.jpg'), URI('2')).ordered
            subject
        end

        context '保存ディレクトリが存在する場合' do
            it 'は保存ディレクトリを作成しない' do
                expect( save_dir_path ).to receive(:exist?).and_return(true)
                expect( save_dir_path ).to_not receive(:mkdir)
                subject
            end
        end

        context '保存ディレクトリが存在しない場合' do
            it 'は保存ディレクトリを作成する' do
                expect( save_dir_path ).to receive(:exist?).and_return(false)
                expect( save_dir_path ).to receive(:mkdir)
                subject
            end
        end
    end
end
