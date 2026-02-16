# frozen_string_literal: true

module Api
  module V1
    class AuthController < Api::V1::BaseController
      skip_before_action :authenticate_request, only: %i[login signup]

      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          token = JsonWebToken.encode({ user_id: user.id })

          render json: {
            token: token,
            user: user.as_json(only: %i[id email role]),
            expires_at: 24.hours.from_now
          }, status: :ok
        else
          render json: { error: 'invalid credentials' }, status: :unauthorized
        end
      end

      def signup
        user = User.new(user_params)

        if user.save
          token = JsonWebToken.encode({ user_id: user.id })
          render json: {
            token: token,
            user: user.as_json(only: %i[id email role]),
            expires_at: 24.hours.from_now
          }, status: :created
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def logout
        Rails.logger.info "User #{current_user.id} logged out"
        head :no_content
      end

      def me
        render json: {
          user: current_user.as_json(only: %i[id email role created_at])
        }
      end

      def refresh
        token = JsonWebToken.encode({ user_id: current_user.id })
        render json: {
          token: token,
          user: current_user.as_json(only: %i[id email role]),
          expires_at: 24.hours.from_now
        }
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
