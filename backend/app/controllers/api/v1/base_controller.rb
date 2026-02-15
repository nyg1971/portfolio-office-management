# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ArgumentError, with: :argument_error
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

      before_action :authenticate_request

      private

      def parameter_missing(exception)
        render json: {
          error: 'パラメータが不足しています',
          message: exception.message
        }, status: :bad_request
      end

      def argument_error(exception)
        render json: {
          error: 'パラメータが不正です',
          message: exception.message
        }, status: :bad_request
      end

      def record_not_found(exception)
        render json: {
          error: 'リソースが見つかりません',
          message: exception.message
        }, status: :not_found
      end

      def record_invalid(exception)
        render json: {
          error: 'バリデーションエラー',
          errors: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      # 指定された役職の権限をチェック
      def authorize_role(required_role)
        return if current_user.public_send(required_role.to_s)

        render json: { error: 'Forbidden Insufficient privileges' }, status: :forbidden
      end

      def authorize_admin
        return if current_user.admin?

        render json: { error: 'Forbidden Admin access required' }, status: :forbidden
      end

      # マネージャー以上の権限チェック（manager または admin）
      def authorize_manager_or_above
        return if current_user.manager? || current_user.admin?

        render json: { error: 'Forbidden: manager role required' }, status: :forbidden
      end

      # 階層的権限チェック（enum数値によるレベル比較）
      def authorize_minimum_role(minimum_role)
        minimum_level = User.roles[minimum_role.to_s]
        current_level = User.roles[current_user.role]

        return if current_level >= minimum_level

        render json: {
          error: "Forbidden #{minimum_role.to_s.humanize} role or above required"
        }, status: :forbidden
      end

      def authenticate_request
        header = request.headers['Authorization']
        if header.present?
          token = header.split.last

          begin
            decoded = JsonWebToken.decode(token)
            @current_user = User.find(decoded[:user_id])
          rescue JWT::DecodeError
            render_unauthorized
          end
        else
          render_unauthorized
        end
      end

      attr_reader :current_user

      def render_unauthorized
        render json: { error: 'unauthorized' }, status: :unauthorized
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          per_page: collection.limit_value,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
