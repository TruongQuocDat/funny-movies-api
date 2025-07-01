# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emotion, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:emotionable) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:video) { create(:video) }
    
    it { should validate_presence_of(:kind) }
    
    it 'validates uniqueness of user_id scoped to emotionable' do
      create(:emotion, user: user, emotionable: video)
      emotion = build(:emotion, user: user, emotionable: video)
      expect(emotion).not_to be_valid
      expect(emotion.errors[:user_id]).to include('has already been taken')
    end

    it 'allows same user to have different emotions on different emotionables' do
      video2 = create(:video)
      create(:emotion, user: user, emotionable: video)
      emotion = build(:emotion, user: user, emotionable: video2)
      expect(emotion).to be_valid
    end

    it 'allows different users to have emotions on same emotionable' do
      user2 = create(:user)
      create(:emotion, user: user, emotionable: video)
      emotion = build(:emotion, user: user2, emotionable: video)
      expect(emotion).to be_valid
    end
  end

  describe 'enums' do
    it 'defines kind enum' do
      expect(Emotion.kinds).to eq({
        'like' => 'like',
        'love' => 'love',
        'angry' => 'angry',
        'dislike' => 'dislike'
      })
    end

    it 'allows setting kind values' do
      emotion = build(:emotion, :like)
      expect(emotion.kind).to eq('like')
      expect(emotion.like?).to be true

      emotion.love!
      expect(emotion.kind).to eq('love')
      expect(emotion.love?).to be true
    end
  end

  describe 'polymorphic associations' do
    it 'can belong to a video' do
      video = create(:video)
      emotion = create(:emotion, emotionable: video)
      expect(emotion.emotionable).to eq(video)
      expect(emotion.emotionable_type).to eq('Video')
    end

    it 'can belong to a comment' do
      comment = create(:comment)
      emotion = create(:emotion, emotionable: comment)
      expect(emotion.emotionable).to eq(comment)
      expect(emotion.emotionable_type).to eq('Comment')
    end
  end
end