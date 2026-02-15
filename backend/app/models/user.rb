# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :work_records, foreign_key: 'staff_user_id', dependent: :destroy, inverse_of: :staff_user
  has_many :assigned_customers, through: :work_records, source: :customer

  # Deviseモジュールの設定（認証機能）
  devise :database_authenticatable, # DB認証（email/password）
         :registerable,             # ユーザー登録機能
         :recoverable,              # パスワードリセット機能
         :rememberable,             # ログイン状態記憶機能
         :validatable               # バリデーション機能（email形式、password長さ等）

  # 役職をenumで定義（整数値で保存、シンボルでアクセス）
  enum :role, {
    staff: 0,     # user.staff? → true/false判定, User.staff → staffユーザー一覧
    manager: 1,   # user.manager? → true/false判定, User.manager → managerユーザー一覧
    admin: 2      # user.admin? → true/false判定, User.admin → adminユーザー一覧
  }
  # roleカラムの存在チェック（必須項目）
  validates :role, presence: true

  # デフォルト値設定
  # after_initialize: オブジェクト初期化後に実行されるコールバック
  # if: :new_record? 条件: 新規レコードの場合のみ実行（更新時は実行しない）
  after_initialize :set_default_role, if: :new_record?

  # API用のJSONシリアライザ
  def as_json_for_api
    {
      id: id,
      email: email,
      role: role,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def set_default_role
    # ||= は「左辺がnil/falseの場合のみ右辺を代入」
    # 既にroleが設定されていれば変更しない、未設定なら:staffを設定
    self.role ||= :staff
  end
end
