# frozen_string_literal: true

class Emotion < ApplicationRecord
  belongs_to :user
  belongs_to :emotionable, polymorphic: true

  enum kind: {
    like: 'like',
    love: 'love',
    angry: 'angry',
    dislike: 'dislike'
  }

  validates :kind, presence: true
  validates :user_id, uniqueness: { scope: [:emotionable_type, :emotionable_id] }
end