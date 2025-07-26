# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: %i[show]
      def index
        @users = User.page(params[:page]).per(params[:per_page] || 20)
        render json: {
          users: @users.map(&:as_json_for_api),
          pagination: pagination_meta(@users)
        }
      end

      # def create
      # end
      def show
        return unless authorize_user_access?(@user)

        render json: {
          user: @user.as_json_for_api
        }
      end
      # def update
      # end
      # def destroy
      # end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def authorize_user_access?(user)
        unless current_user.admin? || current_user.manager? || current_user.id == user.id
          render(json: {
                   error: 'アクセス権限がありません'
                 }, status: :forbidden)
          return false
        end
        true
      end
    end
  end
end
