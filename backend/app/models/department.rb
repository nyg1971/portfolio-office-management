# frozen_string_literal: true

class Department < ApplicationRecord
  include Validatable
  # === アソシエーション ===
  has_many :users, dependent: :restrict_with_error
  # dependent: :restrict_with_error → 所属ユーザーがいる部署は削除不可（安全性重視）
  has_many :customers, dependent: :restrict_with_error
  # dependent: :restrict_with_error → 担当顧客がいる部署は削除不可
  has_many :work_records, through: :customers
  # through関連：部署 → 顧客 → 作業記録の多対多関係
  has_many :assigned_staff, through: :work_records, source: :staff_user
  # この部署に関わる全スタッフとの多対多関係（WorkRecord経由）

  # === バリデーション（データの整合性チェック） ===
  # 部署名
  validates_required :name # 必須バリデーション
  validates_length_with_message :name, max: 100 # 文字数制限バリデーション
  validates_unique :name                        # 一意性バリデーション
  validates_japanese_name :name                 # 日本語名バリデーション
  # 所在地
  validates_length_with_message :address, max: 500 # address は任意項目だが、入力時は文字数制限
  validates_japanese_name :address, allow_blank: true # allow_blank: 空白時はバリデーションスキップ（任意項目対応）

  enum :status, {
    active: 0,      # アクティブ（通常稼働）
    inactive: 1,    # 非アクティブ（一時停止）
    archived: 2     # アーカイブ（廃止済み）
  }, prefix: :status
  # prefix: true → status_active? のようなメソッド名に（名前衝突防止）

  enum :department_type, {
    sales: 0,           # 保護課
    engineering: 1,     # 福祉課
    administration: 2,  # 子ども家庭課
    support: 3,         # 医療助成課
    other: 4 # 医療助成課
  }, prefix: :type
  # prefix: true → type_sales? のようなメソッド名に

  # === スコープ定義（よく使う検索条件） ===
  scope :active, -> { where(status: :active) }
  # アクティブな部署のみ取得

  scope :inactive, -> { where(status: :inactive) }
  # 非アクティブな部署のみ取得

  scope :by_type, ->(type) { where(department_type: type) }
  # 部署タイプでの絞り込み

  scope :with_users, -> { joins(:users).distinct }
  # ユーザーが所属している部署のみ

  scope :with_customers, -> { joins(:customers).distinct }
  # 担当顧客がいる部署のみ

  scope :by_name, ->(name) { where('name ILIKE ?', "%#{name}%") }
  # 部署名での部分一致検索（大文字小文字区別なし）

  scope :recent, -> { where('created_at > ?', 1.month.ago) }
  # 最近作成された部署（1ヶ月以内）

  # === コールバック（自動実行される処理） ===
  before_create :set_initial_status
  # レコード作成前に初期ステータスを設定

  before_destroy :check_dependencies
  # 削除前に依存関係をチェック

  # === クラスメソッド ===
  def self.statistics_by_type
    group(:department_type).count
    # 部署タイプ別の統計を取得（GROUP BY department_type）
  end

  def self.active_departments_with_staff_count
    active.joins(:users)
          .group('departments.id', 'departments.name')
          .count('users.id')
    # アクティブ部署の所属スタッフ数を集計
  end

  def self.search(keyword)
    return all if keyword.blank?

    by_name(keyword)
    # キーワードでの検索（空の場合は全件返却）
  end

  # === インスタンスメソッド ===
  def display_name
    "#{name}（#{department_type_i18n}）"
    # 表示用の部署名（タイプ付き）
  end

  def staff_count
    users.count
    # 所属スタッフ数
  end

  def customer_count
    customers.count
    # 担当顧客数
  end

  def total_work_records
    work_records.count
    # 関連する全作業記録数
  end

  def recent_work_records(days = 7)
    work_records.where('created_at > ?', days.days.ago)
    # 指定日数以内の作業記録
  end

  def can_be_deleted?
    users.empty? && customers.empty?
    # 削除可能かどうか（所属ユーザー・担当顧客が空の場合のみ）
  end

  def activate!
    update!(status: :active)
    # 部署をアクティブ化（!付きで例外発生型）
  end

  def deactivate!
    update!(status: :inactive)
    # 部署を非アクティブ化
  end

  def archive!
    return false unless can_be_deleted?

    update!(status: :archived)
    # アーカイブ化（削除可能な場合のみ）
  end

  private

  # === プライベートメソッド（クラス内部でのみ使用） ===
  def set_initial_status
    self.status ||= :active
    # 初期ステータスをactiveに設定（未設定の場合のみ）
  end

  def check_dependencies
    return if can_be_deleted?

    errors.add(:base, '所属ユーザーまたは担当顧客が存在するため削除できません')
    throw :abort
    # 依存関係がある場合は削除を中止
  end

  def department_type_i18n
    case department_type
    when 'sales' then '営業部'
    when 'engineering' then '技術部'
    when 'administration' then '管理部'
    when 'support' then 'サポート部'
    else 'その他'
    end
    # 部署タイプの日本語表示名
  end
end
