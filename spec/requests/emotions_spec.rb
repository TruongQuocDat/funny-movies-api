# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Emotions', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { generate_token_for(user) }
  let(:video) { create(:video) }
  let(:comment) { create(:comment) }

  describe 'GET /api/v1/videos/:video_id/emotions' do
    before do
      create(:emotion, :like, user: user, emotionable: video)
      create(:emotion, :love, user: other_user, emotionable: video)
      create(:emotion, :like, user: create(:user), emotionable: video)
    end

    it 'returns emotions summary for video' do
      get api_v1_video_emotions_path(video), headers: auth_headers(token)

      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['emotions']).to eq({ 'Like' => 2, 'Love' => 1 })
      expect(json_response['total']).to eq(3)
      expect(json_response['user_emotion']).to eq('like')
    end

    it 'requires authentication' do
      get api_v1_video_emotions_path(video)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/comments/:comment_id/emotions' do
    before do
      create(:emotion, :angry, user: user, emotionable: comment)
      create(:emotion, :dislike, user: other_user, emotionable: comment)
    end

    it 'returns emotions summary for comment' do
      get api_v1_comment_emotions_path(comment), headers: auth_headers(token)

      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['emotions']).to eq({ 'Angry' => 1, 'Dislike' => 1 })
      expect(json_response['total']).to eq(2)
      expect(json_response['user_emotion']).to eq('angry')
    end
  end

  describe 'POST /api/v1/videos/:video_id/emotions' do
    context 'with valid parameters' do
      it 'creates a new emotion' do
        expect {
          post api_v1_video_emotions_path(video),
               params: { emotion: { kind: 'like' } },
               headers: auth_headers(token)
        }.to change(Emotion, :count).by(1)

        expect(response).to have_http_status(:created)
        emotion = Emotion.last
        expect(emotion.user).to eq(user)
        expect(emotion.emotionable).to eq(video)
        expect(emotion.kind).to eq('like')
      end

      it 'updates existing emotion with different kind' do
        create(:emotion, :like, user: user, emotionable: video)

        expect {
          post api_v1_video_emotions_path(video),
               params: { emotion: { kind: 'love' } },
               headers: auth_headers(token)
        }.not_to change(Emotion, :count)

        expect(response).to have_http_status(:ok)
        emotion = user.emotions.find_by(emotionable: video)
        expect(emotion.kind).to eq('love')
      end

      it 'removes emotion when same kind is posted (toggle behavior)' do
        create(:emotion, :like, user: user, emotionable: video)

        expect {
          post api_v1_video_emotions_path(video),
               params: { emotion: { kind: 'like' } },
               headers: auth_headers(token)
        }.to change(Emotion, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Emotion removed')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for invalid kind' do
        post api_v1_video_emotions_path(video),
             params: { emotion: { kind: 'invalid_kind' } },
             headers: auth_headers(token)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'requires authentication' do
      post api_v1_video_emotions_path(video),
           params: { emotion: { kind: 'like' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/comments/:comment_id/emotions' do
    it 'creates emotion for comment' do
      expect {
        post api_v1_comment_emotions_path(comment),
             params: { emotion: { kind: 'love' } },
             headers: auth_headers(token)
      }.to change(Emotion, :count).by(1)

      expect(response).to have_http_status(:created)
      emotion = Emotion.last
      expect(emotion.emotionable).to eq(comment)
    end
  end

  describe 'DELETE /api/v1/videos/:video_id/emotions' do
    context 'when user has emotion' do
      before do
        create(:emotion, :like, user: user, emotionable: video)
      end

      it 'removes the emotion' do
        expect {
          delete api_v1_video_emotions_path(video), headers: auth_headers(token)
        }.to change(Emotion, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Emotion removed')
      end
    end

    context 'when user has no emotion' do
      it 'returns not found error' do
        delete api_v1_video_emotions_path(video), headers: auth_headers(token)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('No emotion found')
      end
    end

    it 'requires authentication' do
      delete api_v1_video_emotions_path(video)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/comments/:comment_id/emotions' do
    context 'when user has emotion' do
      before do
        create(:emotion, :angry, user: user, emotionable: comment)
      end

      it 'removes the emotion' do
        expect {
          delete api_v1_comment_emotions_path(comment), headers: auth_headers(token)
        }.to change(Emotion, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  private

  def auth_headers(token)
    { 'Authorization' => "Bearer #{token}" }
  end
end