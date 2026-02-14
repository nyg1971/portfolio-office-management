# frozen_string_literal: true

module Validatable
  module ValidationHelpers
    private

    # 複数属性に対するユニークネスバリデーション共通処理
    # @param attributes [Array<Symbol>] 属性名配列
    # @param message_key [Symbol] メッセージキー
    # @param options [Hash] バリデーションオプション
    def validates_uniqueness_for_attributes(attributes, message_key, **options)
      attributes.each do |attribute|
        validation_data = prepare_validation_for_attribute(attribute, message_key)

        validates attribute, uniqueness: {
          message: "#{validation_data[:display_name]}#{validation_data[:message]}"
        }.merge(options)
      end
    end

    # 複数属性に対するプレゼンスバリデーション共通処理
    # @param attributes [Array<Symbol>] 属性名配列
    # @param message_key [Symbol] メッセージキー
    # @param options [Hash] バリデーションオプション
    def validates_presence_for_attributes(attributes, message_key, **options)
      attributes.each do |attribute|
        validation_data = prepare_validation_for_attribute(attribute, message_key)

        validates attribute, presence: {
          message: "#{validation_data[:display_name]}#{validation_data[:message]}"
        }.merge(options)
      end
    end

    # 複数属性に対するフォーマットバリデーション共通処理
    # @param attributes [Array<Symbol>] 属性名配列
    # @param message_key [Symbol] メッセージキー
    # @param regex_pattern [Regexp] 正規表現パターン
    # @param options [Hash] バリデーションオプション
    def validates_format_for_attributes(attributes, message_key, regex_pattern, **options)
      attributes.each do |attribute|
        validation_data = prepare_validation_for_attribute(attribute, message_key)

        validates attribute, format: {
          with: regex_pattern,
          message: "#{validation_data[:display_name]}#{validation_data[:message]}"
        }.merge(options)
      end
    end

    # 属性に対する共通バリデーション前処理
    # @param attribute [Symbol] 属性名
    # @param message_key [Symbol] メッセージキー
    # @param interpolations [Hash] 補間用のハッシュ
    # @return [Hash] display_name と message を含むハッシュ
    def prepare_validation_for_attribute(attribute, message_key, interpolations = {})
      validate_attribute_is_managed!(attribute)
      {
        display_name: get_display_name_for_attribute(attribute),
        message: get_validation_message(message_key, interpolations)
      }
    end

    # 複数属性に対するinclusionバリデーション共通処理
    # @param attributes [Array<Symbol>] バリデーション対象の属性名配列
    # @param message_key [Symbol] メッセージキー（統一システム用、現在は:inclusionを使用）
    # @param choices [Array, Range] 許可される値の配列または範囲
    # @param options [Hash] Rails標準のvalidatesオプション
    # @return [void]
    # @raise [Validatable::ConfigurationManager::AttributeNotManagedError] 属性が設定ファイルで管理されていない場合
    def validates_inclusion_for_attributes(attributes, _message_key, choices:, **options)
      attributes.each do |attribute|
        validate_attribute_is_managed!(attribute)
        display_name = get_display_name_for_attribute(attribute)
        choices_text = choices.is_a?(Array) ? choices.join('、') : choices.to_s

        validates attribute, inclusion: {
          in: choices,
          message: "#{display_name}は有効な値ではありません（選択肢: #{choices_text}）"
        }.merge(options)
      end
    end

    # 属性に対応するenum値を取得
    # @param attribute [Symbol] 属性名
    # @return [Array<String>] enum値の配列
    # @raise [ArgumentError] 属性がenumとして定義されていない場合
    def get_enum_values_for_attribute(attribute)
      # 一時的にハードコードで解決
      case attribute.to_s
      when 'customer_type'
        return %w[regular premium corporate]
      when 'status'
        return %w[active inactive pending]
      end

      raise ArgumentError, "#{attribute} はenumとして定義されていません。モデル: #{name}"
    end
  end
end
