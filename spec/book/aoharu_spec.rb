# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Book::Aoharu do
    let(:book){ described_class.new 'http://aoharu.jp/comic/identifier/1/' }

    describe '#lazy_load' do
        subject{ book.__send__ :lazy_load }

        before{
            allow( book ).to receive(:get).and_return(responce('/book/aoharu/1_vertical.html'))
        }

        it 'はhtmlを取得する' do
            expect( book ).to receive(:get).with(URI('http://aoharu.jp/comic/identifier/1/')).and_return(responce('/book/aoharu/1_vertical.html'))
            expect( subject ).to eql true
        end

        context '縦型ビューアの場合' do
            before{
                allow( book ).to receive(:get).and_return(responce('/book/aoharu/1_vertical.html'))
            }

            it 'は@pagesを設定する' do
                subject

                expect( book.pages.to_a ).to eq [
                    URI('http://aoharu.jp/comic/identifier/1/iPhone/ipad/1/1.jpg'),
                    URI('http://aoharu.jp/comic/identifier/1/iPhone/ipad/1/2.jpg'),
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

        context '横型ビューアの場合' do
            # before{
            #     allow( book ).to receive(:get).and_return(responce('/fixtures/aoharu/1_horizonal.html'))
            # }

            # it 'はsuperを使用する' do
            #     expect( book ).to receive(:lazy_load).and_return('super')
            #     expect( subject ).to eql 'super'
            # end
        end
    end
end
