# frozen_string_literal: true

class Customer < ApplicationRecord
  include Validatable

  # === アソシエーション ===
  belongs_to :department                        # 顧客は必ず単一の部署に所属する
  has_many :work_records, dependent: :destroy   # 顧客削除時に関連する作業記録も削除
  has_many :assigned_users, through: :work_records, source: :staff_user # 担当スタッフを取得

  # === バリデーション (Validatableモジュール使用) ===
  # 氏名 (必須、100文字制限)
  validates_required :name
  validates_length_with_message :name, maximum: 100

  # ステータス (必須、enum指定値のみ)
  validates_required :status
  validates_enum_inclusion :status

  # 顧客タイプ (必須、enum指定値のみ)
  validates_required :customer_type
  validates_enum_inclusion :customer_type

  # === enum定義 ===
  enum :status, {
    active: 0,
    inactive: 1,
    pending: 2
  }, prefix: :status

  enum :customer_type, {
    regular: 0,
    premium: 1,
    corporate: 2
  }, prefix: :type

  # === コールバック ===
  # 作成前に初期値設定
  before_create :set_initial_status

  private

  # 初期ステータスを設定
  def set_initial_status
    self.status ||= :pending
  end
end
