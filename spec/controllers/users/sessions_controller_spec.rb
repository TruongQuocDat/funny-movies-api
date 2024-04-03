# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Sessions', type: :request do
  let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }

  describe 'POST /users/sign_in' do
    context 'with valid credentials' do
      before do
        post user_session_path, params: { user: { email: 'user@example.com', password: 'password123' } }
      end

      it 'authenticates the user and returns a JWT token' do
        expect(response).to have_http_status(:ok)
        expect(response.headers['Authorization']).to be_present
      end
    end

    context 'with invalid credentials' do
      before do
        post user_session_path, params: { user: { email: 'user@example.com', password: 'wrong-password' } }
      end

      it 'does not authenticate the user' do
        expect(response).to have_http_status(:unauthorized)
        expect(response.headers['Authorization']).to be_nil
      end
    end
  end
end
