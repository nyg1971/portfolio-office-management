# frozen_string_literal: true

module Validatable
  class MessageManager
    class << self
      # バリデーションメッセージをロケール別にロードする
      # @param locale [Symbol, String] ロケール（デフォルト: I18n.locale）
      # @return [Hash] メッセージハッシュ（キー: メッセージ種別、値: メッセージ文字列）
      # @example
      #   MessageManager.load_messages(:ja)
      #   # => { "presence" => "は必須です", "email" => "の形式が正しくありません", ... }
      def load_messages(locale = I18n.locale)
        @messages ||= {}
        @messages[locale] ||= load_messages_from_file(locale)
      end

      # 指定されたキーのバリデーションメッセージを取得する
      # @param key [String, Symbol] メッセージキー（例: :presence, :email）
      # @param locale [Symbol, String] ロケール（デフォルト: I18n.locale）
      # @return [String] バリデーションメッセージ文字列
      # @example
      #   MessageManager.get_message(:presence)
      #   # => "は必須です"
      #   MessageManager.get_message(:email, :en)
      #   # => " format is invalid"
      def get_message(key, locale = I18n.locale)
        messages = load_messages(locale)
        messages[key.to_s] || key.to_s.humanize
      end

      # プレースホルダーを含むメッセージを文字列補間して取得する
      # @param key [String, Symbol] メッセージキー
      # @param interpolations [Hash] 補間用の値（例: { count: 100 }）
      # @param locale [Symbol, String] ロケール（デフォルト: I18n.locale）
      # @return [String] 補間済みメッセージ文字列
      # @example
      #   MessageManager.get_formatted_message(:too_long, { count: 100 })
      #   # => "は100文字以内で入力してください"
      #   MessageManager.get_formatted_message(:greater_than, { count: 18 })
      #   # => "は18より大きい値を入力してください"
      def get_formatted_message(key, interpolations = {}, locale = I18n.locale)
        message = get_message(key, locale)
        interpolations.reduce(message) do |msg, (key, value)|
          msg.gsub("%{#{key}}", value.to_s)
        end
      end

      # 指定ロケールの全バリデーションメッセージを一覧表示する（デバッグ・確認用）
      # @param locale [Symbol, String] ロケール（デフォルト: I18n.locale）
      # @return [void] 標準出力にメッセージ一覧を表示
      # @example
      #   MessageManager.list_all_messages
      #   # === バリデーションメッセージ一覧 (ja) ===
      #   # presence                 : "は必須です"
      #   # email                    : "の形式が正しくありません（例：user@example.com）"
      #   # ...
      def list_all_messages(locale = I18n.locale)
        Rails.logger.debug { "=== バリデーションメッセージ一覧 (#{locale}) ===" }
        load_messages(locale).each do |key, message|
          Rails.logger.debug "#{key.ljust(25)}: \"#{message}\""
        end
      end

      # 利用可能なロケール一覧を取得する
      # @return [Array<String>] 利用可能なロケールの配列
      # @example
      #   MessageManager.available_locales
      #   # => ["validation_messages", "en", "ja", "zh"]
      def available_locales
        Rails.root.glob('config/validation_messages/*.yml')
             .map { |path| File.basename(path, '.yml') }
             .push('validation_messages')
             .uniq
      end

      private

      # 指定ロケールのメッセージファイルを読み込む
      # 多言語ファイル（config/validation_messages/locale.yml）を優先し、
      # 存在しない場合はデフォルトファイル（config/validation_messages.yml）を使用
      # @param locale [Symbol, String] ロケール
      # @return [Hash] メッセージハッシュ
      # @example 読み込み優先順位
      #   1. config/validation_messages/ja.yml （ロケール固有ファイル）
      #   2. config/validation_messages.yml    （デフォルトファイル）
      def load_messages_from_file(locale)
        # 多言語ファイルを優先
        locale_file = Rails.root.join('config', 'validation_messages', "#{locale}.yml")
        default_file = Rails.root.join('config/validation_messages.yml')

        file_to_load = File.exist?(locale_file) ? locale_file : default_file

        begin
          config = YAML.load_file(file_to_load)
          config['validation_messages'] || {}
        rescue StandardError => e
          Rails.logger.warn "メッセージファイル読み込み失敗: #{file_to_load} - #{e.message}"
          {}
        end
      end
    end
  end
end
