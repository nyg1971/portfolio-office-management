# frozen_string_literal: true

class User < ApplicationRecord
  include Validatable

  # === アソシエーション ===
  has_many :work_records, foreign_key: 'staff_user_id', dependent: :destroy, inverse_of: :staff_user # 顧客削除時に関連する作業記録も削除
  has_many :assigned_customers, through: :work_records, source: :customer # 担当顧客を取得

  # Deviseモジュールの設定（認証機能）
  devise :database_authenticatable, # DB認証（email/password）
         :registerable,             # ユーザー登録機能
         :recoverable,              # パスワードリセット機能
         :rememberable,             # ログイン状態記憶機能
         :validatable               # バリデーション機能（email形式、password長さ等）

  # === バリデーション (Validatableモジュール使用) ===
  # 役職 (必須)
  validates_required :role

  # === enum定義 ===
  enum :role, {
    staff: 0,
    manager: 1,
    admin: 2
  }

  # === コールバック ===
  # デフォルト値設定
  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    # 既にroleが設定されていれば変更しない、未設定なら:staffを設定
    self.role ||= :staff
  end
end
