# frozen_string_literal: true

class WorkRecord < ApplicationRecord
  # 統一バリデーションシステムを使用
  include Validatable

  # ========================================
  # アソシエーション（関連設定）
  # ========================================

  # 作業対象顧客との一対多関係
  belongs_to :customer

  # 作業担当スタッフとの一対多関係（Userモデルを参照）
  belongs_to :staff_user, class_name: 'User', inverse_of: :work_records

  # 所属部署との一対多関係
  belongs_to :department

  # ========================================
  # バリデーション（検証ルール）
  # ========================================

  # 作業内容は必須（空欄不可）
  validates_required :content

  # 作業日は必須（空欄不可）
  validates_required :work_date

  # 作業内容の文字数制限（最大1000文字）
  validates_length_with_message :content, max: 1000

  # 作業タイプと状態は enum で検証されるため、個別バリデーション不要

  # ========================================
  # enum定義（状態管理）
  # ========================================

  # 作業状況の管理
  enum :status, {
    in_progress: 0,   # 進行中
    completed: 1,     # 完了
    on_hold: 2,       # 保留
    cancelled: 3      # キャンセル
  }, prefix: :status

  # 作業タイプの分類
  enum :work_type, {
    consultation: 0,  # 相談対応
    support: 1,       # サポート作業
    maintenance: 2,   # 保守・メンテナンス
    emergency: 3      # 緊急対応
  }, prefix: :type

  # ========================================
  # スコープ定義（よく使う検索条件）
  # ========================================

  # 作成日時の新しい順で並替
  scope :recent, -> { order(created_at: :desc) }

  # 作業日の新しい順で並替
  scope :by_work_date, -> { order(work_date: :desc) }

  # 指定部署の作業記録のみ
  scope :by_department, ->(dept) { where(department: dept) }

  # 指定顧客の作業記録のみ
  scope :by_customer, ->(customer) { where(customer: customer) }

  # 指定スタッフの作業記録のみ
  scope :by_staff, ->(staff) { where(staff_user: staff) }

  # 指定期間の作業記録（開始日〜終了日）
  scope :in_period, lambda { |start_date, end_date|
    where(work_date: start_date.beginning_of_day..end_date.end_of_day)
  }

  # 今月の作業記録
  scope :this_month, lambda {
    where(work_date: Time.current.all_month)
  }

  # 先月の作業記録
  scope :last_month, lambda {
    where(work_date: 1.month.ago.all_month)
  }

  # 今週の作業記録
  scope :this_week, lambda {
    where(work_date: Time.current.all_week)
  }

  # 完了済みの作業記録のみ
  scope :completed_works, -> { where(status: :completed) }

  # 進行中の作業記録のみ
  scope :active_works, -> { where(status: :in_progress) }

  # 緊急対応の作業記録のみ
  scope :emergency_works, -> { where(work_type: :emergency) }

  # ========================================
  # インスタンスメソッド（個別レコードの操作）
  # ========================================

  # 作業が完了しているかチェック
  # @return [Boolean] 完了状態の場合 true
  # @example
  #   work_record.completed? # => true/false
  def completed?
    status_completed?
  end

  # 緊急作業かどうかチェック
  # @return [Boolean] 緊急作業の場合 true
  # @example
  #   work_record.urgent? # => true/false
  def urgent?
    work_type_emergency?
  end

  # 進行中の作業かどうかチェック
  # @return [Boolean] 進行中の場合 true
  # @example
  #   work_record.in_progress? # => true/false
  def active?
    status_in_progress?
  end

  # 作業完了処理（状態を完了に変更し、完了日時を記録）
  # @return [Boolean] 更新成功時 true
  # @example
  #   work_record.mark_as_completed!
  def mark_as_completed!
    update!(
      status: :completed,
      completed_at: Time.current
    )
  end

  # 作業保留処理（状態を保留に変更）
  # @param reason [String] 保留理由（任意）
  # @return [Boolean] 更新成功時 true
  # @example
  #   work_record.mark_as_on_hold!("顧客都合により")
  def mark_as_on_hold!(reason = nil)
    update!(
      status: :on_hold,
      notes: reason ? "保留理由: #{reason}" : notes
    )
  end

  # 作業再開処理（保留状態から進行中に戻す）
  # @return [Boolean] 更新成功時 true
  # @example
  #   work_record.resume!
  def resume!
    update!(status: :in_progress) if status_on_hold?
  end

  # 作業時間の計算（開始〜完了までの時間）
  # @return [Float] 作業時間（時間単位）
  # @example
  #   work_record.duration_hours # => 2.5（2時間30分）
  def duration_hours
    return 0.0 unless completed_at && created_at

    ((completed_at - created_at) / 1.hour).round(2)
  end

  # 作業記録の要約文字列を生成
  # @return [String] 作業記録の概要
  # @example
  #   work_record.summary
  #   # => "2024/01/15 - 田中太郎様（相談対応）"
  def summary
    date_str = work_date.strftime('%Y/%m/%d')
    customer_name = customer&.name || '顧客不明'
    type_str = I18n.t("activerecord.attributes.work_record.work_types.#{work_type}", default: work_type.humanize)

    "#{date_str} - #{customer_name}様（#{type_str}）"
  end

  # APIレスポンス用のJSON形式データを生成
  # @return [Hash] API用のハッシュデータ
  # @example
  #   work_record.as_json_for_api
  def as_json_for_api
    {
      id: id,
      content: content,
      work_date: work_date.strftime('%Y-%m-%d'),
      work_type: work_type,
      work_type_display: I18n.t("activerecord.attributes.work_record.work_types.#{work_type}",
                                default: work_type.humanize),
      status: status,
      status_display: I18n.t("activerecord.attributes.work_record.statuses.#{status}", default: status.humanize),
      duration_hours: duration_hours,
      customer: {
        id: customer.id,
        name: customer.name
      },
      staff_user: {
        id: staff_user.id,
        name: staff_user.name
      },
      department: {
        id: department.id,
        name: department.name
      },
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601
    }
  end

  # ========================================
  # クラスメソッド（モデル全体の操作・統計）
  # ========================================

  class << self
    # 指定期間の作業記録統計を取得
    # @param start_date [Date] 開始日
    # @param end_date [Date] 終了日
    # @return [Hash] 統計データ
    # @example
    #   WorkRecord.statistics_for_period(1.month.ago, Date.current)
    def statistics_for_period(start_date, end_date)
      records = in_period(start_date, end_date)

      {
        total_count: records.count,
        completed_count: records.completed_works.count,
        emergency_count: records.emergency_works.count,
        average_duration: records.completed_works.average(:duration_hours)&.round(2) || 0.0,
        by_work_type: records.group(:work_type).count,
        by_status: records.group(:status).count,
        by_department: records.joins(:department).group('departments.name').count
      }
    end

    # 指定スタッフの作業負荷を分析
    # @param staff_user [User] 分析対象のスタッフ
    # @param period [Integer] 分析期間（日数、デフォルト30日）
    # @return [Hash] 作業負荷データ
    # @example
    #   WorkRecord.workload_analysis(user, 30)
    def workload_analysis(staff_user, period = 30)
      start_date = period.days.ago
      records = by_staff(staff_user).in_period(start_date, Date.current)

      {
        total_works: records.count,
        completed_works: records.completed_works.count,
        completion_rate: (records.completed_works.count.to_f / records.count * 100).round(2),
        emergency_works: records.emergency_works.count,
        average_daily_works: (records.count.to_f / period).round(2),
        customers_served: records.distinct.count(:customer_id)
      }
    end

    # 人気の作業タイプランキング
    # @param limit [Integer] 上位何位まで取得するか（デフォルト5位）
    # @return [Array<Hash>] ランキングデータ
    # @example
    #   WorkRecord.popular_work_types(3)
    def popular_work_types(limit = 5)
      group(:work_type)
        .order('count_all DESC')
        .limit(limit)
        .count
        .map do |work_type, count|
        {
          work_type: work_type,
          display_name: I18n.t("activerecord.attributes.work_record.work_types.#{work_type}",
                               default: work_type.humanize),
          count: count
        }
      end
    end

    # 部署別の作業効率分析
    # @return [Array<Hash>] 部署別効率データ
    # @example
    #   WorkRecord.efficiency_by_department
    def efficiency_by_department
      grouped_data = joins(:department)
                     .group('departments.name')
                     .group(:status)
                     .count

      dept_summary = grouped_data.each_with_object({}) do |(key, count), result|
        dept_name, status = key
        result[dept_name] ||= { total: 0, completed: 0 }
        result[dept_name][:total] += count
        result[dept_name][:completed] += count if status == 'completed'
      end

      dept_efficiency = dept_summary.map do |dept_name, data|
        completion_rate = (data[:completed].to_f / data[:total] * 100).round(2)
        {
          department: dept_name,
          total_works: data[:total],
          completed_works: data[:completed],
          completion_rate: completion_rate
        }
      end

      dept_efficiency.sort_by { |dept| -dept[:completion_rate] }
    end
  end

  # ========================================
  # コールバック（自動処理）
  # ========================================

  # 作業記録作成前の処理
  before_create :set_default_status

  # 作業完了時の処理
  after_update :notify_completion, if: :saved_change_to_status?

  private

  # デフォルト状態を進行中に設定
  def set_default_status
    self.status ||= :in_progress
  end

  # 作業完了時の通知処理
  def notify_completion
    return unless status_completed? && status_previously_was != 'completed'

    # ここで通知サービスを呼び出し
    # NotificationService.notify_work_completed(self)
    Rails.logger.info "作業完了通知: #{summary}"
  end
end

# ========================================
# 使用例とテストコマンド
# ========================================

#
# Rails Console での動作確認コマンド
#
# 1. 基本的な作業記録作成
# customer = Customer.first
# staff = User.first
# department = Department.first
#
# work_record = WorkRecord.create!(
#   customer: customer,
#   staff_user: staff,
#   department: department,
#   content: "顧客からの問い合わせ対応",
#   work_date: Date.current,
#   work_type: :consultation
# )
#
# 2. 作業記録の検索・フィルタリング
# WorkRecord.recent.limit(10)
# WorkRecord.by_department(department)
# WorkRecord.this_month.emergency_works
# WorkRecord.completed_works.by_staff(staff)
#
# 3. 統計データの取得
# WorkRecord.statistics_for_period(1.month.ago, Date.current)
# WorkRecord.workload_analysis(staff, 30)
# WorkRecord.popular_work_types(5)
# WorkRecord.efficiency_by_department
#
# 4. 作業状態の変更
# work_record.mark_as_completed!
# work_record.mark_as_on_hold!("顧客都合により一時保留")
# work_record.resume!
#
# 5. API用データの生成
# work_record.as_json_for_api
#
# 6. 関連データの取得（through関連の活用）
# customer.assigned_users.distinct  # この顧客の担当スタッフ一覧
# staff.assigned_customers.distinct # このスタッフの担当顧客一覧
#
