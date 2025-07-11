# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from StandardError, with: :internal_server_error

  private

  def internal_server_error(exception)
    render json: {
      error: 'サーバ内部エラー',
      message: Rails.env.production? ? 'Internal Server Error' : exception.message
    }, status: :internal_server_error
  end
end
