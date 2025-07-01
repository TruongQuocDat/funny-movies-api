# frozen_string_literal: true

module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!, except: [:index]
      before_action :set_video, only: %i[index create]
      before_action :set_comment, only: %i[create_reply]

      def index
        @comments = @video.comments.root_comments.includes(:replies, :user)
        render json: @comments, include: { user: {}, replies: { include: :user } }
      end

      def create
        @comment = @video.comments.build(comment_params)
        @comment.user = current_user

        if @comment.save
          render json: @comment, include: :user, status: :created
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def create_reply
        @reply = @comment.replies.build(reply_params)
        @reply.user = current_user
        @reply.video = @comment.video

        if @reply.save
          render json: @reply, include: :user, status: :created
        else
          render json: { errors: @reply.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_video
        @video = Video.find(params[:video_id])
      end

      def set_comment
        @comment = Comment.find(params[:comment_id])
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def reply_params
        params.require(:comment).permit(:content)
      end
    end
  end
end