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
FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.sentence }
    association :user
    association :video
    parent { nil }

    trait :with_reply do
      after(:create) do |comment|
        create(:comment, parent: comment, video: comment.video)
      end
    end
  end
end
