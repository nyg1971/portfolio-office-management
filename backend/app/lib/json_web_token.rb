# frozen_string_literal: true

class JsonWebToken
  # Railsの秘密鍵を使用（config/credentials.yml.encから取得）
  # この鍵でJWTの署名・検証を行う（セキュリティの要）
  SECRET_KEY = Rails.application.credentials.secret_key_base
  # JWTトークン生成
  def self.encode(payload, exp = 24.hours.from_now)
    # payloadにexpiration（有効期限）を追加
    # exp.to_i = Unix時間（1970年からの秒数）に変換
    payload[:exp] = exp.to_i
    # JWT.encode(データ, 秘密鍵) でトークン生成
    # 結果: "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE2ODc..." 形式
    JWT.encode(payload, SECRET_KEY)
  end

  # JWTトークン解読
  def self.decode(token)
    # JWT.decode(トークン, 秘密鍵) で解読
    # 戻り値は配列 [payload, header] なので[0]でpayloadを取得
    decode = JWT.decode(token, SECRET_KEY)[0]

    # HashWithIndifferentAccess: 文字列キー・シンボルキー両方でアクセス可能
    # decoded[:user_id] でも decoded["user_id"] でもアクセス可能になる
    ActiveSupport::HashWithIndifferentAccess.new decode
  rescue JWT::DecodeError => e
    # トークンが無効（改ざん、期限切れ等）の場合はエラーを再発生
    # Controller側でrescueしてUnauthorizedレスポンスを返す
    raise e
  end
end
