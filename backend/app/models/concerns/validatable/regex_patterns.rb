# frozen_string_literal: true

module Validatable
  module RegexPatterns
    # === 日本語系正規表現 ===
    # ひらがな・カタカナ・漢字・英数字・ハイフン・長音符・スペース
    JAPANESE_NAME_FORMAT = /\A[\p{Hiragana}\p{Katakana}\p{Han}a-zA-Z0-9\s\-ー]+\z/

    # 住所用（括弧も含む）
    JAPANESE_ADDRESS_FORMAT = /\A[\p{Hiragana}\p{Katakana}\p{Han}a-zA-Z0-9\s\-ー０-９（）()]+\z/

    # カタカナのみ（フリガナ等）
    KATAKANA_FORMAT = /\A[\p{Katakana}ー\s]+\z/

    # ひらがなのみ
    HIRAGANA_FORMAT = /\A[\p{Hiragana}\s]+\z/

    # === 連絡先系正規表現 ===
    # メールアドレス（RFC準拠の簡易版）
    EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

    # 電話番号（ハイフン区切り）
    PHONE_FORMAT = /\A\d{2,4}-\d{2,4}-\d{4}\z/

    # 携帯電話（より厳密）
    MOBILE_PHONE_FORMAT = /\A0[789]0-\d{4}-\d{4}\z/

    # 郵便番号（日本形式）
    POSTAL_CODE_FORMAT = /\A\d{3}-\d{4}\z/

    # === 識別子系正規表現 ===
    # 英数字のみ（ID・コード等）
    ALPHANUMERIC_FORMAT = /\A[a-zA-Z0-9]+\z/

    # 英数字とハイフン・アンダースコア（ユーザー名等）
    USERNAME_FORMAT = /\A[a-zA-Z0-9\-_]+\z/

    # 英字のみ
    ALPHA_FORMAT = /\A[a-zA-Z]+\z/

    # 数字のみ
    NUMERIC_FORMAT = /\A\d+\z/

    # === URL・ウェブ系正規表現 ===
    # URL（http/https）
    URL_FORMAT = %r{\Ahttps?://[\w/:%#\$&\?\(\)~\.=\+\-]+\z}

    # ドメイン名
    DOMAIN_FORMAT = /\A[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}\z/

    # === 金融・ビジネス系正規表現 ===
    # クレジットカード番号（基本形）
    CREDIT_CARD_FORMAT = /\A\d{4}-\d{4}-\d{4}-\d{4}\z/

    # 銀行口座番号（7桁）
    BANK_ACCOUNT_FORMAT = /\A\d{7}\z/

    # === パスワード系正規表現 ===
    # 強いパスワード（英大小数字記号を含む8文字以上）
    STRONG_PASSWORD_FORMAT = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/

    # 中程度パスワード（英数字8文字以上）
    MEDIUM_PASSWORD_FORMAT = /\A[a-zA-Z\d]{8,}\z/

    # === 全パターン一覧取得 ===
    def self.all_patterns
      constants.select { |const| const.to_s.end_with?('_FORMAT') }
               .index_with { |const| const_get(const) }
    end

    def self.list_all_patterns
      Rails.logger.debug '=== 利用可能な正規表現パターン ==='
      all_patterns.each do |name, pattern|
        Rails.logger.debug "#{name.to_s.ljust(30)} : #{pattern.source}"
      end
    end

    def self.test_pattern(pattern_name, test_string)
      pattern = const_get(pattern_name)
      result = test_string.match?(pattern)
      Rails.logger.debug { "#{pattern_name}: '#{test_string}' => #{result ? '✅ マッチ' : '❌ 不一致'}" }
    rescue NameError
      Rails.logger.debug { "❌ パターン '#{pattern_name}' が見つかりません" }
    end
  end
end
