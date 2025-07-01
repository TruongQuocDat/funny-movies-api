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
require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:video) }
    it { should belong_to(:parent).class_name('Comment').optional }
    it { should have_many(:replies).class_name('Comment').with_foreign_key('parent_id').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }

    it 'is valid with valid attributes' do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it 'is not valid without content' do
      comment = build(:comment, content: nil)
      expect(comment).not_to be_valid
    end

    it 'is not valid without a user' do
      comment = build(:comment, user: nil)
      expect(comment).not_to be_valid
    end

    it 'is not valid without a video' do
      comment = build(:comment, video: nil)
      expect(comment).not_to be_valid
    end
  end

  describe 'scopes' do
    let(:video) { create(:video) }
    let!(:root_comment) { create(:comment, video: video) }
    let!(:reply) { create(:comment, video: video, parent: root_comment) }

    describe '.root_comments' do
      it 'returns only comments without parent' do
        expect(Comment.root_comments).to include(root_comment)
        expect(Comment.root_comments).not_to include(reply)
      end
    end
  end

  describe 'nested comments' do
    let(:video) { create(:video) }
    let(:parent_comment) { create(:comment, video: video) }

    it 'can have replies' do
      reply = create(:comment, video: video, parent: parent_comment)
      expect(parent_comment.replies).to include(reply)
    end

    it 'reply belongs to parent comment' do
      reply = create(:comment, video: video, parent: parent_comment)
      expect(reply.parent).to eq(parent_comment)
    end

    it 'destroys replies when parent is destroyed' do
      reply = create(:comment, video: video, parent: parent_comment)
      expect { parent_comment.destroy }.to change(Comment, :count).by(-2)
    end
  end
end
