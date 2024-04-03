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
FactoryBot.define do
  factory :jwt_denylist do
    jti { SecureRandom.uuid }
    exp { 1.day.from_now }
  end
end
