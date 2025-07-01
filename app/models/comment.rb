# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint
#  user_id    :bigint           not null
#  video_id   :bigint           not null
#
# Indexes
#
#  index_comments_on_parent_id  (parent_id)
#  index_comments_on_user_id    (user_id)
#  index_comments_on_video_id   (video_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => comments.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (video_id => videos.id)
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :video
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validates :content, presence: true

  scope :root_comments, -> { where(parent_id: nil) }
  scope :with_replies, -> { includes(:replies) }
end
