# frozen_string_literal: true

class WorkRecord < ApplicationRecord
  include Validatable

  # === アソシエーション ===
  belongs_to :customer # 作業記録は必ず単一の顧客に紐づく
  belongs_to :staff_user, class_name: 'User', inverse_of: :work_records # 作業記録は必ず単一の作業担当スタッフに紐づく
  belongs_to :department # 作業記録は必ず単一の部署に紐づく

  # === バリデーション (Validatableモジュール使用) ===
  # 作業内容 (必須、1000文字数制限)
  validates_required :content
  validates_length_with_message :content, max: 1000

  # 作業日 (必須)
  validates_required :work_date
  # 作業タイプと状態は enum で検証されるため、個別バリデーション不要

  # === enum定義 ===
  enum :status, {
    in_progress: 0,
    completed: 1,
    on_hold: 2,
    cancelled: 3
  }, prefix: :status

  enum :work_type, {
    consultation: 0,
    support: 1,
    maintenance: 2,
    emergency: 3
  }, prefix: :type

  # === コールバック ===
  # 作業記録作成前の処理
  before_create :set_default_status

  private

  # デフォルト状態を進行中に設定
  def set_default_status
    self.status ||= :in_progress
  end
end
