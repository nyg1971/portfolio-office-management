# frozen_string_literal: true

# 基底コントローラー
module Api
  module V1
    class BaseController < ApplicationController
      # 全てのアクションの前に認証チェックを実行
      # このコントローラーを継承する全てのControllerで認証が必要になる
      before_action :authenticate_request

      private

      # 指定された役職以上の権限をチェックする汎用メソッド
      def authorise_role(required_role)
        # current_user.public_send("#{required_role}?")
        # → current_user.staff? や current_user.manager? を動的に呼び出し
        # public_send = セキュアなメソッド呼び出し（メソッドが存在しない場合はエラー）
        return if current_user.public_send(required_role.to_s)

        render json: { error: 'Forbidden Insufficient privileges' }, status: :forbidden
      end

      # 管理者権限専用チェック（admin のみ許可）
      def authorise_admin
        # admin? = Userモデルのenum role で自動生成されるメソッド
        # user.admin? → true/false を返す
        return if current_user.admin?

        render json: { error: 'Forbidden Admin access required' }, status: :forbidden
      end

      # マネージャー以上の権限チェック（manager または admin）
      def authorize_manager_or_above
        # ||演算子 で「managerまたはadmin」の条件をチェック
        # staff(0) < manager(1) < admin(2) の階層構造
        return if current_user.manager? || current_user.admin?

        render json: { error: 'Forbidden: manager role required' }, status: :forbidden
      end

      # より柔軟な階層的権限チェック（レベル比較）
      def authorise_minimum_role(minimum_role)
        # User.roles[minimum_role] でenumの数値を取得
        # User.roles = {"staff"=>0, "manager"=>1, "admin"=>2}
        minimum_level = User.roles[minimum_role.to_s]
        current_level = User.roles[current_user.role]

        # 現在のユーザーの権限レベルが最低要求レベル未満の場合はエラー
        return if current_level >= minimum_level

        render json: {
          error: "Forbidden #{minimum_role.to_s.humanise} role or above required"
        }, status: :forbidden
      end

      # JWT認証メソッド
      def authenticate_request
        # HTTPヘッダーからAuthorizationを取得
        # 例: "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
        header = request.headers['Authorization']
        if header.present?
          # "Bearer TOKEN" から TOKEN部分を抽出
          # split(' ').last で空白で分割し最後の要素（トークン）を取得
          token = header.split.last

          begin
            # JsonWebTokenクラスでトークンを解読
            decoded = JsonWebToken.decode(token)

            # 解読結果からuser_idを取得してユーザーを特定
            # @current_user = インスタンス変数（アクション内でも使用可能）
            @current_user = User.find(decoded[:user_id])
          rescue JWT::DecodeError
            # 改ざん、期限切れ、形式不正等でエラーになった場合
            render_unauthorized
          end
        else # Authorizationヘッダーが存在しない場合
          render_unauthorized
        end
      end

      # 認証済みユーザーを取得するヘルパーメソッド
      # 継承先のControllerで current_user として呼び出し可能
      attr_reader :current_user

      # 認証失敗時のエラーレスポンス
      def render_unauthorized
        # HTTP 401 Unauthorized + JSONエラーメッセージ
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
    end
  end
end
