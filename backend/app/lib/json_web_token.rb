# frozen_string_literal: true

class JsonWebToken
  # FIXME: CI環境でcredentialsを復号できないケースがあるため、
  # ENV["SECRET_KEY_BASE"] へのフォールバックを暫定的に設定している。
  # 将来的にはJWT専用の秘密鍵を分離管理する。
  SECRET_KEY =
    Rails.application.credentials.secret_key_base.presence ||
    ENV.fetch('SECRET_KEY_BASE', nil)

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    ActiveSupport::HashWithIndifferentAccess.new decoded
  end
end
