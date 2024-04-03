# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :request do
  describe 'POST /users' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        { user: attributes_for(:user) }
      end

      it 'creates a new user' do
        expect do
          post user_registration_path, params: valid_attributes
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json['user']).to include('email' => valid_attributes[:user][:email])
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        { user: attributes_for(:user, email: '') }
      end

      it 'does not create a user and returns errors' do
        expect do
          post user_registration_path, params: invalid_attributes
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

# Helper method to parse JSON responses
def json
  JSON.parse(response.body)
end
