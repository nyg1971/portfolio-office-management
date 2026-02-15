# frozen_string_literal: true

class ValidationChecker
  class YamlSyntaxChecker
    def run
      Rails.logger.debug '=== YAML構文チェック開始 ==='

      validation_files = Rails.root.glob('config/validations/*.yml')
      errors = []

      if validation_files.empty?
        Rails.logger.debug '⚠️  検証対象のYAMLファイルが見つかりません'
        return
      end

      validation_files.each do |file_path|
        validate_yaml_file(file_path, errors)
      end

      print_summary('YAML構文チェック', "#{validation_files.size}個のファイル", errors)
    end

    private

    def validate_yaml_file(file_path, errors)
      file_name = File.basename(file_path)
      Rails.logger.debug { "#{file_name}を検証中..." }

      content = YAML.load_file(file_path)
      validate_yaml_content(content, file_path, file_name, errors)
    rescue Psych::SyntaxError => e
      errors << "#{file_name}: YAML構文エラー - #{e.message}"
    rescue StandardError => e
      errors << "#{file_name}: 読み込みエラー - #{e.message}"
    end

    def validate_yaml_content(content, file_path, file_name, errors)
      if content.nil?
        errors << "#{file_name}: ファイルが空またはnullです"
      elsif !content.is_a?(Hash)
        errors << "#{file_name}: ルートレベルがハッシュではありません"
      else
        validate_yaml_structure(content, file_path, file_name, errors)
      end
    end

    def validate_yaml_structure(content, file_path, file_name, errors)
      model_name = File.basename(file_path, '.yml')

      unless content.key?(model_name)
        errors << "#{file_name}: モデル名キー '#{model_name}' が見つかりません"
        return
      end

      model_config = content[model_name]
      unless model_config.is_a?(Hash)
        errors << "#{file_name}: モデル設定がハッシュではありません"
        return
      end

      Rails.logger.debug { "  ✅ 構文OK - #{model_config.keys.size}個の属性定義" }
      choices_count = count_choices(model_config)
      Rails.logger.debug { "  📋 選択肢表示名: #{choices_count}個" } if choices_count.positive?
    end

    def count_choices(model_config)
      model_config.each_value.sum do |attr_config|
        attr_config.is_a?(Hash) && attr_config['choices_display'] ? attr_config['choices_display'].size : 0
      end
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
