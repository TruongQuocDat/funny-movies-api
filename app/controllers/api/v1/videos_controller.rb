# frozen_string_literal: true

module Api
  module V1
    class VideosController < ApplicationController
      before_action :authenticate_user!, except: [:index]

      def index
        @videos = Video.includes(:user).all

        render json: @videos
      end

      def create
        video_info = YoutubeService.new(params[:url]).call

        if video_info[:error].nil?
          video = Video.new(title: video_info[:title],
                            description: video_info[:description],
                            url: params[:url],
                            user_id: current_user.id)

          if video.save
            BroadcastNotificationsJob.perform_later({ title: video.title, user: video.user.name })

            render json: video, status: :created
          else
            render json: { errors: video.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: video_info[:error] }, status: :bad_request
        end
      end
    end
  end
end
