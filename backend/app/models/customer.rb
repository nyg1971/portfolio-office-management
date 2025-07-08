# frozen_string_literal: true

class Customer < ApplicationRecord
  include Validatable
  # 担当スタッフ一覧（WorkRecord経由でUser取得）
  # @!attribute [r] assigned_users
  #   @return [ActiveRecord::Relation<User>]
  # === アソシエーション（関連設定） ===
  belongs_to :department                        # 必須：顧客は必ず部署に所属する
  has_many :work_records, dependent: :destroy   # 顧客削除時に関連する作業記録も削除
  has_many :assigned_users, through: :work_records, source: :staff_user # 担当スタッフの一覧を取得

  # === バリデーション ===
  # 氏名の検証
  validates_required :name # 必須項目：空文字・nil禁止
  validates_length_with_message :name, maximum: 100 # 最大100文字制限（DB制約とUI制約を兼ねる）
  validates_japanese_name :name

  # 顧客タイプの検証
  validates_required :customer_type # 必須項目：顧客分類は必ず設定
  validates_enum_inclusion :customer_type # 指定値のみ許可（セキュリティ対策）

  # ステータスの検証
  validates_required :status # 必須項目：ステータスは必ず設定
  validates_enum_inclusion :status

  # === enum定義（数値→文字列マッピング） ===

  # ステータス管理（顧客の現在の状態）
  enum :status, {
    active: 0,    # アクティブ：通常の顧客（サービス利用中）
    inactive: 1,  # 非アクティブ：休眠顧客（一時的にサービス停止）
    pending: 2    # 保留：新規登録処理中や審査中の顧客
  }, prefix: :status
  enum :customer_type, {
    regular: 0,
    premium: 1,
    corporate: 2
  }, prefix: :type

  # === スコープ（よく使う条件での絞り込み） ===

  # アクティブな顧客のみ取得（最も頻繁に使用）
  scope :active_customers, -> { where(status: :active) }

  # 顧客タイプ別の絞り込み
  scope :premium_customers, -> { where(customer_type: 'premium') }
  scope :corporate_customers, -> { where(customer_type: 'corporate') }

  # 部署別の顧客取得
  scope :by_department, ->(dep) { where(department: dep) }

  # 最近作成された顧客（1ヶ月以内）
  scope :recent, -> { where(created_at: 1.month.ago..Time.current) }

  # === インスタンスメソッド（ビジネスロジック） ===

  # 表示用の顧客名（タイプ付き）
  def display_name
    case customer_type
    when 'premium'
      "#{name} [プレミアム]"
    when 'corporate'
      "#{name} [法人]"
    else
      name
    end
  end

  # VIP顧客判定
  def vip?
    %w[premium corporate].include?(customer_type)
  end

  # 最近の活動があるか判定（30日以内に作業記録がある）
  def recently_active?
    work_records.exists?(created_at: 30.days.ago..Time.current)
  end

  # 担当スタッフ数の取得
  def assigned_staff_count
    assigned_users.distinct.count
  end

  # === クラスメソッド（集計・検索機能） ===

  # 顧客タイプ別の統計情報
  def self.statics_by_type
    group(:customer_type).count
  end

  # ステータス別の統計情報
  def self.statics_by_status
    group(:status).count
  end

  # 名前での部分一致検索
  def self.search_by_name(query)
    return all if query.blank?

    where('name LIKE ?', "%#{query}%") # PostgreSQL用：大文字小文字を区別しない部分一致
  end

  # === コールバック（自動実行される処理） ===

  # 作成前に初期値設定
  before_create :set_initial_status

  private

  # 初期ステータスを設定（明示的に指定されていない場合）
  def set_initial_status
    self.status ||= :pending
  end
end
