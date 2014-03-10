# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Extensions::String do
  let(:string){ 'abcdef' }
  let(:extended_string){ string.extend EBookloader::Extensions::String }

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

  describe '#expand_each' do
    context 'ブロックを渡さなかった場合' do
      let(:string){ 'file[1-3]' }
      subject{ extended_string.expand_each }

      it 'はEnumeratorを返す' do
        expect( subject ).to be_a Enumerator
      end

      it 'は展開してeachする' do
        expect{|b| subject.each(&b) }.to yield_successive_args(
          ['file1', ['1']],
          ['file2', ['2']],
          ['file3', ['3']]
        )
      end
    end

    context '範囲' do
      context '数値の範囲の場合' do
        let(:string){ 'file[1-3]' }

        it 'は展開してeachする' do
          expect{|b| extended_string.expand_each(&b) }.to yield_successive_args(
            ['file1', ['1']],
            ['file2', ['2']],
            ['file3', ['3']]
          )
        end
      end

      context '桁数がある数値の範囲の場合' do
        let(:string){ 'file[01-3]' }

        it 'は展開してeachする' do
          expect{|b| extended_string.expand_each(&b) }.to yield_successive_args(
            ['file01', ['01']],
            ['file02', ['02']],
            ['file03', ['03']]
          )
        end
      end

      context '文字の範囲の場合' do
        let(:string){ 'file[_aa-_ac]' }

        it 'は展開してeachする' do
          expect{|b| extended_string.expand_each(&b) }.to yield_successive_args(
            ['file_aa', ['_aa']],
            ['file_ab', ['_ab']],
            ['file_ac', ['_ac']]
          )
        end
      end

      context 'スキップ付きの範囲の場合' do
        let(:string){ 'file[1-6:2]' }

        it 'は展開してeachする' do
          expect{|b| extended_string.expand_each(&b) }.to yield_successive_args(
            ['file1', ['1']],
            ['file3', ['3']],
            ['file5', ['5']]
          )
        end
      end
    end

    context '選択の場合' do
      let(:string){ 'file{,_aaa,_001}' }

      it 'は展開してeachする' do
        expect{|b| extended_string.expand_each(&b) }.to yield_successive_args(
          ['file', ['']],
          ['file_aaa', ['_aaa']],
          ['file_001', ['_001']]
        )
      end
    end

    context '複数の場合' do
      let(:string){ 'file[1-3]{_a,_b}' }

      it 'は個別に展開してeachする' do
        expect{|b| extended_string.expand_each(&b) }.to yield_successive_args(
          ['file1_a', ['1', '_a']],
          ['file1_b', ['1', '_b']],
          ['file2_a', ['2', '_a']],
          ['file2_b', ['2', '_b']],
          ['file3_a', ['3', '_a']],
          ['file3_b', ['3', '_b']]
        )
      end
    end
  end
end
