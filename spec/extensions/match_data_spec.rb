# coding: utf-8

require_relative '../spec_helper.rb'

describe EBookloader::Extensions::MatchData do
  let(:match_data){ '12345abcde54321'.match /^(?<num>\d+)(?<char>[a-zA-Z]+)(\d+)$/ }
  let(:extended_match_data){ match_data.extend EBookloader::Extensions::MatchData }

  describe '#to_hash' do
    subject{ extended_match_data.to_hash }

    it 'はHashを返す' do
      expect( subject ).to eql({num: '12345', char: 'abcde'})
    end
  end
end
