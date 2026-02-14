# frozen_string_literal: true

module Validatable
  # 基本的なバリデーションメソッド
  module BasicValidators
    # 必須バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_required(*attributes, **options)
      validates_presence_for_attributes(attributes, :presence, **options)
    end

    # 一意性バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_unique(*attributes, **options)
      validates_uniqueness_for_attributes(attributes, :taken, **options)
    end

    # 文字数制限バリデーション
    # @param attribute [Symbol] 属性名
    # @param min [Integer, nil] 最小文字数
    # @param max [Integer, nil] 最大文字数
    # @param options [Hash] バリデーションオプション
    def validates_length_with_message(attribute, min: nil, max: nil, **options)
      validation_data = prepare_validation_for_attribute(attribute, :presence) # ダミーキー

      length_options = {}
      if max
        length_options[:maximum] = max
        length_options[:too_long] = "#{validation_data[:display_name]}#{get_validation_message(:too_long, count: max)}"
      end
      if min
        length_options[:minimum] = min
        length_options[:too_short] =
          "#{validation_data[:display_name]}#{get_validation_message(:too_short, count: min)}"
      end

      validates attribute, length: length_options.merge(options)
    end
  end
end
