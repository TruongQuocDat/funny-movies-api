# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:user) { build(:user) }

    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user.password = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without a name' do
      user.name = nil
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: user.email)
      expect(user).not_to be_valid
    end
  end

  describe '.decode_jwt_token' do
    let(:user) { create(:user) }
    let(:jwt_token) { Devise::JWT::TestHelpers.auth_headers({}, user)['Authorization'].split.last }

    it 'decodes a valid JWT token' do
      decoded_data = User.decode_jwt_token(jwt_token)
      expect(decoded_data).not_to be_nil
      expect(decoded_data['sub']).to eq(user.id.to_s)
    end

    it 'returns nil for an invalid JWT token' do
      expect(User.decode_jwt_token('invalid.token')).to be_nil
    end
  end
end
