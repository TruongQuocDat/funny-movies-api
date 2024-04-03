# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      payload = User.decode_jwt_token(token)
      if payload && (user = User.find_by(id: payload['sub']))
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
