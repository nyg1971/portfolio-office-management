# frozen_string_literal: true

module Validatable
  # フォーマット検証メソッド（正規表現ベース）
  module FormatValidators
    # 日本語名バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_japanese_name(*attributes, **options)
      validates_format_for_attributes(attributes, :japanese_name, RegexPatterns::JAPANESE_NAME_FORMAT, **options)
    end

    # メールアドレスバリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_email(*attributes, **options)
      validates_format_for_attributes(attributes, :email, RegexPatterns::EMAIL_FORMAT, **options)
    end

    # 電話番号バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_phone(*attributes, **options)
      validates_format_for_attributes(attributes, :phone, RegexPatterns::PHONE_FORMAT, **options)
    end

    # 携帯電話番号バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_mobile_phone(*attributes, **options)
      validates_format_for_attributes(attributes, :mobile_phone, RegexPatterns::MOBILE_PHONE_FORMAT, **options)
    end

    # 英数字バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_alphanumeric(*attributes, **options)
      validates_format_for_attributes(attributes, :alphanumeric, RegexPatterns::ALPHANUMERIC_FORMAT, **options)
    end

    # ユーザー名バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_username(*attributes, **options)
      validates_format_for_attributes(attributes, :username, RegexPatterns::USERNAME_FORMAT, **options)
    end

    # URL バリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_url(*attributes, **options)
      validates_format_for_attributes(attributes, :url, RegexPatterns::URL_FORMAT, **options)
    end

    # 強いパスワードバリデーション
    # @param attributes [Array<Symbol>] 属性名配列
    # @param options [Hash] バリデーションオプション
    def validates_strong_password(*attributes, **options)
      validates_format_for_attributes(attributes, :strong_password, RegexPatterns::STRONG_PASSWORD_FORMAT, **options)
    end
  end
end
