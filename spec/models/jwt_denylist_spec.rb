# frozen_string_literal: true

# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime         not null
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti)
#
require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  it 'has a valid factory' do
    expect(build(:jwt_denylist)).to be_valid
  end

  describe 'validations' do
    before do
      create(:jwt_denylist)
    end

    it { should validate_presence_of(:jti) }
    it { should validate_presence_of(:exp) }

    it { should validate_uniqueness_of(:jti) }
  end
end
