# frozen_string_literal: true

module Validatable
  class ConfigurationManager
    class << self
      # モデル名と属性名から表示名を取得する
      def get_display_name(model_name, attribute_name)
        config = load_model_config(model_name)
        attribute_config = config.dig(model_name.to_s, attribute_name.to_s)

        if attribute_config && attribute_config['display_name']
          attribute_config['display_name']
        else
          # フォールバック：属性名をヒューマナイズ
          attribute_name.to_s.humanize
        end
      end

      # 属性が管理対象かどうかをチェックし、管理外の場合は例外を発生させる
      def validate_attribute_managed!(model_name, attribute_name)
        return if attribute_managed?(model_name, attribute_name)

        raise AttributeNotManagedError.new(model_name, attribute_name)
      end

      # 属性が管理対象かどうかをチェックする
      def attribute_managed?(model_name, attribute_name)
        config = load_model_config(model_name)
        config.dig(model_name.to_s, attribute_name.to_s).present?
      end

      # 指定モデルの管理対象属性一覧を取得する
      def managed_attributes(model_name)
        config = load_model_config(model_name)
        model_config = config[model_name.to_s] || {}
        model_config.keys
      end

      # 指定モデルの全設定を取得する（デバッグ・確認用）
      def get_model_config(model_name)
        load_model_config(model_name)
      end

      # モデル名と属性名からenum値とその表示名のハッシュを取得する
      def get_choice_display_names(model_name, attribute_name)
        config = load_model_config(model_name)
        attribute_config = config.dig(model_name.to_s, attribute_name.to_s)

        if attribute_config && attribute_config['choices_display']
          attribute_config['choices_display']
        else
          Rails.logger.warn "choices_display設定が見つかりません: #{model_name}##{attribute_name}"
          {}
        end
      rescue StandardError => e
        Rails.logger.error "choices_display取得失敗: #{model_name}##{attribute_name} - #{e.message}"
        {}
      end

      # 利用可能なモデル設定ファイル一覧を取得する
      def available_models
        Rails.root.glob('config/validations/*.yml')
             .map { |path| File.basename(path, '.yml') }
             .sort
      end

      # 全モデルの設定を一覧表示する（デバッグ用）
      def list_all_configurations
        Rails.logger.debug '=== モデル設定一覧 ==='
        available_models.each do |model_name|
          Rails.logger.debug { "#{model_name.classify}:" }
          managed_attributes(model_name).each do |attr_name|
            display_name = get_display_name(model_name, attr_name)
            Rails.logger.debug { "  #{attr_name.ljust(20)}: \"#{display_name}\"" }
          end
          Rails.logger.debug ''
        end
      end

      private

      # 指定モデルの設定ファイルを読み込む（キャッシュ付き）
      def load_model_config(model_name)
        @model_configs ||= {}
        @model_configs[model_name] ||= load_config_from_file(model_name)
      end

      # 指定モデルの設定ファイルから設定を読み込む
      def load_config_from_file(model_name)
        config_file = Rails.root.join('config', 'validations', "#{model_name}.yml")

        unless File.exist?(config_file)
          Rails.logger.warn "設定ファイルが見つかりません: #{config_file}"
          return {}
        end

        begin
          YAML.load_file(config_file) || {}
        rescue StandardError => e
          Rails.logger.error "設定ファイル読み込み失敗: #{config_file} - #{e.message}"
          {}
        end
      end
    end

    # カスタム例外クラス：管理外属性エラー
    class AttributeNotManagedError < StandardError
      def initialize(model_name, attribute_name)
        @model_name = model_name
        @attribute_name = attribute_name
        super(build_error_message)
      end

      private

      def build_error_message
        available_attrs = ConfigurationManager.managed_attributes(@model_name)

        message = "属性 ':#{@attribute_name}' は#{@model_name}モデルで管理されていません。\n\n"
        message += "対応方法:\n"
        message += "1. config/validations/#{@model_name}.yml に属性を追加\n"
        message += "2. 既存の管理対象属性を使用\n\n"

        if available_attrs.any?
          message += "管理対象属性: #{available_attrs.join(', ')}\n\n"

          # 類似属性の提案
          similar_attr = find_similar_attribute(available_attrs)
          message += "もしかして ':#{similar_attr}' ですか？" if similar_attr
        else
          message += "現在、#{@model_name}モデルには管理対象属性がありません。"
        end

        message
      end

      def find_similar_attribute(available_attrs)
        target = @attribute_name.to_s.downcase

        # 完全マッチ（大文字小文字の違いのみ）
        exact_match = available_attrs.find { |attr| attr.downcase == target }
        return exact_match if exact_match

        # 部分マッチ
        partial_match = available_attrs.find { |attr| attr.include?(target) || target.include?(attr) }
        return partial_match if partial_match

        # 編集距離による類似度チェック（簡易版）
        available_attrs.min_by do |attr|
          levenshtein_distance(target, attr.downcase)
        end
      end

      def levenshtein_distance(str1, str2)
        matrix = Array.new(str1.length + 1) { Array.new(str2.length + 1) }

        (0..str1.length).each { |i| matrix[i][0] = i }
        (0..str2.length).each { |j| matrix[0][j] = j }

        (1..str1.length).each do |i|
          (1..str2.length).each do |j|
            cost = str1[i - 1] == str2[j - 1] ? 0 : 1
            matrix[i][j] = [
              matrix[i - 1][j] + 1,      # 削除
              matrix[i][j - 1] + 1,      # 挿入
              matrix[i - 1][j - 1] + cost # 置換
            ].min
          end
        end

        matrix[str1.length][str2.length]
      end
    end
  end
end
