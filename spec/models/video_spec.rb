# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_videos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Video, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:url) }

    it 'is valid with valid attributes' do
      user = create(:user)
      video = build(:video, user:)
      expect(video).to be_valid
    end

    it 'is not valid without a title' do
      video = build(:video, title: nil)
      expect(video).not_to be_valid
    end

    it 'is not valid without a URL' do
      video = build(:video, url: nil)
      expect(video).not_to be_valid
    end

    it 'is valid with a valid URL format' do
      video = build(:video, url: 'http://example.com/video.mp4')
      expect(video).to be_valid
    end

    it 'is not valid with an invalid URL format' do
      video = build(:video, url: 'invalid_url')
      expect(video).not_to be_valid
    end
  end
end
