# coding: utf-8

require_relative 'spec_helper.rb'

describe EBookloader::StringExtensions do
  let(:string){ 'abcdef' }
  let(:extended_string){ string.extend EBookloader::StringExtensions }

  describe '#global_match' do
    let(:regexp){ /(?<char>...)/ }

    let(:match1){ string.match /(?<char>...)/, 0 }
    let(:match2){ string.match /(?<char>...)/, 3 }
    let(:match3){ string.match /(?<char>...)/, 6 }

    context 'ブロックを渡さなかった場合' do
      subject{ extended_string.global_match regexp }

      it 'はEnumeratorを返す' do
        expect( subject ).to be_a Enumerator
      end

      it 'は文字列のmatchを繰り返しMatchDataを渡す' do
        expect( regexp ).to receive(:match).with(extended_string, 0).ordered.and_return(match1)
        expect( regexp ).to receive(:match).with(extended_string, 3).ordered.and_return(match2)
        expect( regexp ).to receive(:match).with(extended_string, 6).ordered.and_return(match3)

        expect( subject.next ).to eql match1
        expect( subject.next ).to eql match2
        expect{ subject.next }.to raise_error StopIteration
      end
    end

    context 'ブロックを渡した場合' do
      subject{ extended_string.global_match(regexp){} }

      it 'はselfを返す' do
        expect( subject ).to equal extended_string
      end

      it 'は文字列のmatchを繰り返す' do
        expect( regexp ).to receive(:match).with(extended_string, 0).ordered.and_return(match1)
        expect( regexp ).to receive(:match).with(extended_string, 3).ordered.and_return(match2)
        expect( regexp ).to receive(:match).with(extended_string, 6).ordered.and_return(match3)
        expect{ |b| extended_string.global_match(regexp, &b) }.to yield_successive_args(match1, match2)
      end
    end
  end
end
