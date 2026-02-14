# frozen_string_literal: true

module Validatable
  # 設定・メッセージ管理のヘルパーメソッド
  module ConfigurationHelpers
    # モデル名を小文字で取得（バリデーション用）
    # @return [String] モデル名（小文字）
    def model_name_for_validation
      name.demodulize.downcase
    end

    # 属性の表示名を取得
    # @param attribute_name [Symbol, String] 属性名
    # @return [String] 属性の表示名
    def get_display_name_for_attribute(attribute_name)
      ConfigurationManager.get_display_name(model_name_for_validation, attribute_name)
    end

    # バリデーションメッセージを取得
    # @param message_key [Symbol] メッセージキー
    # @param interpolations [Hash] 補間用のハッシュ
    # @return [String] フォーマット済みメッセージ
    def get_validation_message(message_key, interpolations = {})
      MessageManager.get_formatted_message(message_key, interpolations)
    end

    # 属性が設定ファイルで管理されているか検証
    # @param attribute_name [Symbol, String] 属性名
    # @raise [Validatable::ConfigurationManager::AttributeNotManagedError] 属性が管理されていない場合
    def validate_attribute_is_managed!(attribute_name)
      ConfigurationManager.validate_attribute_managed!(model_name_for_validation, attribute_name)
    end
  end
end
