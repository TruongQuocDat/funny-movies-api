# frozen_string_literal: true

require 'rails_helper'

describe YoutubeService do
  describe '#call' do
    let(:youtube_url) { 'https://www.youtube.com/watch?v=xcJtL7QggTI' }
    let(:service) { described_class.new(youtube_url) }

    context 'when the YouTube API returns a successful response' do
      before do
        stub_request(:get, described_class::BASE_URL)
          .with(query: hash_including(:id, :part, :key))
          .to_return(
            status: 200,
            body: {
              'items' => [
                {
                  'snippet' => {
                    'title' => 'Test Video Title',
                    'description' => 'Test Video Description'
                  }
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns video information' do
        expect(service.call).to eq({
                                     title: 'Test Video Title',
                                     description: 'Test Video Description'
                                   })
      end
    end

    context 'when the YouTube API returns an error' do
      before do
        stub_request(:get, described_class::BASE_URL)
          .with(query: hash_including(:id, :part, :key))
          .to_return(status: 400, body: {}.to_json)
      end

      it 'returns an error message' do
        expect(service.call).to eq({ error: 'Failed to fetch video information' })
      end
    end
  end
end
