# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Videos', type: :request do
  let(:user) { create(:user) }
  let(:token) { generate_token_for(user) }

  describe 'GET /index' do
    let!(:videos) { create_list(:video, 3) }

    it 'returns all videos' do
      get api_v1_videos_path
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      before do
        stub_request(:get, 'https://www.googleapis.com/youtube/v3/videos')
          .with(query: hash_including(:id, :part, :key))
          .to_return(status: 200, body: {
            items: [
              {
                snippet: {
                  title: 'Test Video Title',
                  description: 'Test Video Description'
                }
              }
            ]
          }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      let(:valid_attributes) { { url: 'https://www.youtube.com/watch?v=xcJtL7QggTI' } }

      it 'creates a new Video' do
        headers = { 'Authorization' => "Bearer #{token}" }
        expect do
          post api_v1_videos_path, params: valid_attributes, headers:
        end.to change(Video, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { url: '' } }

      before do
        allow_any_instance_of(YoutubeService).to receive(:call).and_return(error: 'Failed to fetch video information')
      end

      it 'does not create a new Video' do
        headers = { 'Authorization' => "Bearer #{token}" }
        expect do
          post api_v1_videos_path, params: invalid_attributes, headers:
        end.not_to change(Video, :count)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
