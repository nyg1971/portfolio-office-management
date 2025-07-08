# frozen_string_literal: true

module Api
  module V1
    class AuthController < Api::V1::BaseController
      # ログインAPI
      skip_before_action :authenticate_request, only: %i[login signup]
      def login
        # emailでユーザーを検索
        user = User.find_by(email: params[:email])

        # ユーザーが存在 && パスワードが正しい場合
        # valid_password? = Deviseが提供するパスワード検証メソッド
        if user&.valid_password?(params[:password])

          # 認証成功：JWTトークンを生成
          # user_idをペイロードに含めてトークン化
          token = JsonWebToken.encode({ user_id: user.id })

          # 成功レスポンス（JSON形式）
          render json: {
            token: token, # フロントエンドが保存するトークン
            user: user.as_json(only: %i[id email role]), # パスワード等の秘匿情報は除外
            expire_at: 24.hours.from_now                    # トークン有効期限
          }, status: :ok                                    # HTTP 200 OK
        else
          # 認証失敗：ユーザー未存在 or パスワード間違い
          render json: { error: 'invalid credentials' }, status: :unauthorized # HTTP 401
        end
      end

      # サインアップAPI（新規ユーザー登録）
      def signup
        # Strong Parametersで許可されたパラメータのみでユーザー作成
        user = User.new(user_params)

        if user.save # バリデーション通過 & DB保存成功
          # バリデーション通過 & DB保存成功
          token = JsonWebToken.encode({ user_id: user.id })
          # 成功レスポンス
          render json: {
            token: token,
            user: user.as_json(only: %i[id email role]),
            expires_at: 24.hours.from_now
          }, status: :created # HTTP 201 Created
        else
          # 登録失敗：バリデーションエラー（email重複、パスワード不正等）
          render json: {
            errors: user.errors.full_messages # ["Email has already been taken", "Password is too short"]
          }, status: :unprocessable_entity # HTTP 422
        end
      end

      # 認証済みユーザー情報取得API（要JWT認証）
      def me
        # current_user = Base Controllerの authenticate_request で設定済み
        # このメソッドが呼ばれる時点で認証は完了している
        render json: {
          user: current_user.as_json(only: %i[id email role created_at])
        }
        # status省略時は自動的に :ok (HTTP 200)
      end

      private

      # Strong Parameters: セキュリティのため許可するパラメータを明示的に指定
      def user_params
        # params.require(:user) = "user"キーが必須
        # .permit(...) = 指定したキーのみ許可（mass assignment攻撃を防ぐ）
        params.require(:user).permit(:email, :password, :password_confirmation, :role)
      end
    end
  end
end
