# frozen_string_literal: true

module Api
  module V1
    class EmotionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_emotionable

      def index
        emotions_summary = @emotionable.emotions
                                      .group(:kind)
                                      .count
                                      .transform_keys(&:humanize)

        render json: {
          emotions: emotions_summary,
          total: @emotionable.emotions.count,
          user_emotion: current_user_emotion&.kind
        }
      end

      def create
        @emotion = @emotionable.emotions.find_or_initialize_by(user: current_user)
        
        if @emotion.persisted? && @emotion.kind == emotion_params[:kind]
          # If same emotion already exists, remove it (toggle behavior)
          @emotion.destroy
          render json: { message: 'Emotion removed' }, status: :ok
        elsif @emotion.update(emotion_params)
          render json: @emotion, status: @emotion.previously_new_record? ? :created : :ok
        else
          render json: { errors: @emotion.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @emotion = @emotionable.emotions.find_by(user: current_user)
        
        if @emotion
          @emotion.destroy
          render json: { message: 'Emotion removed' }, status: :ok
        else
          render json: { error: 'No emotion found' }, status: :not_found
        end
      end

      private

      def set_emotionable
        if params[:video_id]
          @emotionable = Video.find(params[:video_id])
        elsif params[:comment_id]
          @emotionable = Comment.find(params[:comment_id])
        else
          render json: { error: 'Invalid emotionable type' }, status: :bad_request
        end
      end

      def current_user_emotion
        @current_user_emotion ||= @emotionable.emotions.find_by(user: current_user)
      end

      def emotion_params
        params.require(:emotion).permit(:kind)
      end
    end
  end
end