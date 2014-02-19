# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::LazyLoadable do
    class LazyObject
        include EBookloader::LazyLoadable
    end

    let(:lazy_object){ LazyObject.new }

    describe '#load' do
        subject{ lazy_object.__send__ :load }

        it 'は#lazy_loadを呼び出す' do
            expect( lazy_object ).to receive(:lazy_load)
            subject
        end

        it 'は#lazy_loadがtrueを返した場合はそれ以上呼び出さない' do
            expect( lazy_object ).to receive(:lazy_load).once.and_return(true)
            lazy_object.__send__ :load
            subject
        end

        it 'は#lazy_loadがfalseを返した場合は再び呼び出す' do
            expect( lazy_object ).to receive(:lazy_load).twice.and_return(false)
            lazy_object.__send__ :load
            subject
        end
    end

    describe '#lazy_collection' do
        subject{ lazy_object.__send__ :lazy_collection, source, regexp }
        let(:source){ 'abcdef' }
        let(:regexp){ /(?<char>...)/ }

        let(:match1){ source.match regexp, 0 }
        let(:match2){ source.match regexp, 3 }

        it 'はEnumerator::Lazyを返す' do
            expect( subject ).to be_a Enumerator::Lazy
        end

        describe 'の戻り値のEnumerator::Lazy' do
            it 'は文字列のmatchを繰り返す' do
                expect( regexp ).to receive(:match).with(source, 0).ordered.and_call_original
                expect( regexp ).to receive(:match).with(source, 3).ordered.and_call_original
                expect( regexp ).to receive(:match).with(source, 6).ordered.and_call_original
                subject.force
            end

            context '正順の場合' do
                subject{ lazy_object.__send__ :lazy_collection, source, regexp }

                it 'は逆順にeachする' do
                    expect( subject.to_a ).to eql [match1, match2]
                end
            end

            context '逆順の場合' do
                subject{ lazy_object.__send__ :lazy_collection, source, regexp, true }

                it 'は逆順にeachする' do
                    expect( subject.to_a ).to eql [match2, match1]
                end
            end
        end
    end

    describe '.attr_lazy_reader' do
        before{
            class << lazy_object
                attr_lazy_reader :lazy_property

                def lazy_load
                    @lazy_property = 'lazy_property'
                    true
                end
            end
        }
        subject{ lazy_object.lazy_property }

        it 'は#loadを実行し、インスタンス変数を返すプロパティを作成する' do
            expect( lazy_object ).to receive(:lazy_load).once.and_call_original
            expect( subject ).to eql 'lazy_property'
        end
    end

    describe '.attr_lazy_accessor' do
        before{
            class << lazy_object
                attr_lazy_accessor :lazy_property

                def lazy_load
                    @lazy_property = 'lazy_property'
                    true
                end
            end
        }
        subject{ lazy_object.lazy_property }

        it 'は#loadを実行し、インスタンス変数を返すプロパティを作成する' do
            expect( lazy_object ).to receive(:load).once.and_call_original
            expect( subject ).to eql 'lazy_property'
        end

        it 'はインスタンス変数の値を設定できるプロパティを作成する' do
            lazy_object.lazy_property = 'old_value'
            expect( lazy_object ).to_not receive(:load)
            expect( subject ).to eql 'old_value'
        end
    end
end
