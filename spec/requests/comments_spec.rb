# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Comments', type: :request do
  let(:user) { create(:user) }
  let(:video) { create(:video) }
  let(:token) { generate_token_for(user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/videos/:video_id/comments' do
    let!(:root_comment) { create(:comment, video: video) }
    let!(:reply) { create(:comment, video: video, parent: root_comment) }

    it 'returns all root comments with replies' do
      get "/api/v1/videos/#{video.id}/comments"
      
      expect(response).to have_http_status(:success)
      
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['id']).to eq(root_comment.id)
      expect(json_response.first['replies'].size).to eq(1)
      expect(json_response.first['replies'].first['id']).to eq(reply.id)
    end

    it 'includes user information' do
      get "/api/v1/videos/#{video.id}/comments"
      
      json_response = JSON.parse(response.body)
      expect(json_response.first['user']).to include('name', 'email')
    end
  end

  describe 'POST /api/v1/videos/:video_id/comments' do
    context 'when authenticated' do
      context 'with valid parameters' do
        let(:valid_attributes) { { comment: { content: 'This is a great video!' } } }

        it 'creates a new comment' do
          expect do
            post "/api/v1/videos/#{video.id}/comments", params: valid_attributes, headers: headers
          end.to change(Comment, :count).by(1)

          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['content']).to eq('This is a great video!')
          expect(json_response['user']['id']).to eq(user.id)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_attributes) { { comment: { content: '' } } }

        it 'does not create a comment and returns errors' do
          expect do
            post "/api/v1/videos/#{video.id}/comments", params: invalid_attributes, headers: headers
          end.not_to change(Comment, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['errors']).to include("Content can't be blank")
        end
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        post "/api/v1/videos/#{video.id}/comments", params: { comment: { content: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/comments/:comment_id/replies' do
    let!(:parent_comment) { create(:comment, video: video) }

    context 'when authenticated' do
      context 'with valid parameters' do
        let(:valid_attributes) { { comment: { content: 'This is a reply!' } } }

        it 'creates a new reply' do
          expect do
            post "/api/v1/comments/#{parent_comment.id}/replies", params: valid_attributes, headers: headers
          end.to change(Comment, :count).by(1)

          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['content']).to eq('This is a reply!')
          expect(json_response['user']['id']).to eq(user.id)

          reply = Comment.last
          expect(reply.parent).to eq(parent_comment)
          expect(reply.video).to eq(parent_comment.video)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_attributes) { { comment: { content: '' } } }

        it 'does not create a reply and returns errors' do
          expect do
            post "/api/v1/comments/#{parent_comment.id}/replies", params: invalid_attributes, headers: headers
          end.not_to change(Comment, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['errors']).to include("Content can't be blank")
        end
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        post "/api/v1/comments/#{parent_comment.id}/replies", params: { comment: { content: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end