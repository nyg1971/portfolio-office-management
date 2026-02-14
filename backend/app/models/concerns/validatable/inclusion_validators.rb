# frozen_string_literal: true

module Validatable
  # 選択肢バリデーションメソッド
  module InclusionValidators
    # 選択肢バリデーション（基盤版）
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション（:in オプションで選択肢を指定）
    def validates_inclusion(*attributes, **options)
      choice_list = options.delete(:in)
      validates_inclusion_for_attributes(attributes, :inclusion, choices: choice_list, **options)
    end

    # 選択肢バリデーション(enum)
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_enum_inclusion(*attributes, **options)
      attributes.each do |attribute|
        # 先に管理チェックを実行
        validate_attribute_is_managed!(attribute)

        enum_values = get_enum_values_for_attribute(attribute)
        display_name = get_display_name_for_attribute(attribute)
        choices_text = enum_values.join('、')

        validates attribute, inclusion: {
          in: enum_values,
          message: "#{display_name}は有効な値ではありません（選択肢: #{choices_text}）"
        }.merge(options)
      end
    end
  end
end
