# frozen_string_literal: true

class Department < ApplicationRecord
  include Validatable

  # === アソシエーション ===
  has_many :users, dependent: :restrict_with_error # 所属ユーザーがいる部署は削除不可
  has_many :customers, dependent: :restrict_with_error # 担当顧客がいる部署は削除不可
  has_many :work_records, through: :customers # 部署 → 顧客 → 作業記録
  has_many :assigned_staff, through: :work_records, source: :staff_user # この部署に関わる全スタッフ（WorkRecord経由）

  # === バリデーション (Validatableモジュール使用) ===
  # 部署名 (必須、100文字制限、ユニーク制限、日本語表記のみ)
  validates_required :name
  validates_length_with_message :name, max: 100
  validates_unique :name
  validates_japanese_name :name

  # 所在地 (任意項目だが入力時は500文字数制限、空白時はバリデーションスキップ)
  validates_length_with_message :address, max: 500
  validates_japanese_name :address, allow_blank: true

  # === enum定義 ===
  enum :status, {
    active: 0,
    inactive: 1,
    archived: 2
  }, prefix: :status

  enum :department_type, {
    sales: 0,
    engineering: 1,
    administration: 2,
    support: 3,
    other: 4
  }, prefix: :type

  private

  def set_initial_status
    # 初期ステータスをactiveに設定（未設定の場合のみ）
    self.status ||= :active
  end
end
