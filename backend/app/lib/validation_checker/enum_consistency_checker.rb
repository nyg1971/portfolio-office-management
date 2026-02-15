# frozen_string_literal: true

class ValidationChecker
  class EnumConsistencyChecker
    def run
      Rails.logger.debug '=== enum-YAML整合性チェック開始 ==='

      errors = []
      warnings = []
      models_with_enums = find_models_with_enums

      models_with_enums.each { |model_class| check_model_enums(model_class, errors, warnings) }

      print_summary('整合性チェック', "#{models_with_enums.size}個のモデル", errors, warnings)
    end

    private

    def check_model_enums(model_class, errors, warnings)
      Rails.logger.debug { "\n#{model_class.name}を検証中..." }

      model_class.defined_enums.each do |enum_name, enum_values|
        Rails.logger.debug { "  enum #{enum_name}: #{enum_values.keys.join(', ')}" }
        check_enum_consistency(model_class, enum_name, enum_values, errors, warnings)
      end
    end

    def find_models_with_enums
      model_files = Rails.root.glob('app/models/**/*.rb')
      models = model_files.filter_map { |file_path| load_model_with_enums(file_path) }
      models.sort_by(&:name)
    end

    def load_model_with_enums(file_path)
      relative_path = file_path.sub(Rails.root.join('app/models/').to_s, '').sub('.rb', '')
      class_name = relative_path.camelize
      klass = class_name.constantize

      klass if klass.is_a?(Class) && klass < ApplicationRecord && klass.defined_enums.any?
    rescue NameError
      nil
    rescue StandardError => e
      Rails.logger.debug { "⚠️  #{class_name}の読み込みをスキップ: #{e.message}" }
      nil
    end

    def check_enum_consistency(model_class, enum_name, enum_values, errors, warnings)
      yaml_choices = fetch_yaml_choices(model_class, enum_name)

      if yaml_choices.empty?
        warnings << "#{model_class.name}##{enum_name}: YAML設定にchoices_displayが見つかりません"
        return
      end

      enum_keys = enum_values.keys.map(&:to_s)
      yaml_keys = yaml_choices.keys.map(&:to_s)

      check_missing_keys(model_class, enum_name, enum_keys, yaml_keys, errors)
      check_extra_keys(model_class, enum_name, enum_keys, yaml_keys, warnings)
      log_consistency_success(enum_keys, yaml_keys, yaml_choices)
    rescue StandardError => e
      errors << "#{model_class.name}##{enum_name}: YAML設定読み込みエラー - #{e.message}"
    end

    def fetch_yaml_choices(model_class, enum_name)
      model_name = model_class.name.demodulize.downcase
      Validatable::ConfigurationManager.get_choice_display_names(model_name, enum_name)
    end

    def check_missing_keys(model_class, enum_name, enum_keys, yaml_keys, errors)
      missing_in_yaml = enum_keys - yaml_keys
      return if missing_in_yaml.empty?

      errors << "#{model_class.name}##{enum_name}: YAML設定に不足している値: #{missing_in_yaml.join(', ')}"
    end

    def check_extra_keys(model_class, enum_name, enum_keys, yaml_keys, warnings)
      extra_in_yaml = yaml_keys - enum_keys
      return if extra_in_yaml.empty?

      warnings << "#{model_class.name}##{enum_name}: YAML設定に余分な値: #{extra_in_yaml.join(', ')}"
    end

    def log_consistency_success(enum_keys, yaml_keys, yaml_choices)
      return unless (enum_keys - yaml_keys).empty? && (yaml_keys - enum_keys).empty?

      Rails.logger.debug { "    ✅ 整合性OK (#{enum_keys.size}個の値が一致)" }
      yaml_choices.each { |key, display_name| Rails.logger.debug "      #{key}: #{display_name}" }
    end

    def print_summary(check_name, target_description, errors, warnings = [])
      Rails.logger.debug { "\n=== #{check_name}結果 ===" }
      Rails.logger.debug { "検証対象: #{target_description}" }
      log_warnings(warnings)
      log_errors_or_success(check_name, errors)
    end

    def log_warnings(warnings)
      return unless warnings.any?

      Rails.logger.debug { "\n⚠️  警告 (#{warnings.size}件):" }
      warnings.each { |warning| Rails.logger.debug "  - #{warning}" }
    end

    def log_errors_or_success(check_name, errors)
      if errors.any?
        Rails.logger.debug { "\n❌ エラー (#{errors.size}件):" }
        errors.each { |error| Rails.logger.debug "  - #{error}" }
        raise "#{check_name}でエラーが検出されました (#{errors.size}件)"
      else
        Rails.logger.debug { "\n✅ #{check_name}完了: 問題ありません" }
      end
    end
  end
end
