# frozen_string_literal: true

module Validatable
  extend ActiveSupport::Concern
  # 正規表現定義
  include RegexPatterns

  class_methods do
    include Validatable::ConfigurationHelpers # 設定・メッセージ管理のヘルパーメソッド
    include Validatable::FormatValidators     # フォーマット検証メソッド（正規表現ベース）
    include Validatable::BasicValidators      # 基本的なバリデーションメソッド
    include Validatable::InclusionValidators  # 選択肢バリデーションメソッド
    include Validatable::ValidationHelpers    # バリデーション内部ヘルパーメソッド
  end
end
