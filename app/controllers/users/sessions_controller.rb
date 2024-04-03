# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: { user: resource, jwt: request.env['warden-jwt_auth.token'] }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
