# frozen_string_literal: true

namespace :validations do
  desc 'enum-YAML整合性チェック'
  task validate_consistency: :environment do
    puts '=== enum-YAML整合性チェック開始 ==='

    errors = []
    warnings = []

    # モデルファイルを検索してenum定義を持つモデルを特定
    models_with_enums = find_models_with_enums

    models_with_enums.each do |model_class|
      model_name = model_class.name.demodulize.downcase
      puts "\n#{model_class.name}を検証中..."

      model_class.defined_enums.each do |enum_name, enum_values|
        puts "  enum #{enum_name}: #{enum_values.keys.join(', ')}"

        # YAML設定ファイルから選択肢表示名を取得
        begin
          yaml_choices = Validatable::ConfigurationManager.get_choice_display_names(model_name, enum_name)

          if yaml_choices.empty?
            warnings << "#{model_class.name}##{enum_name}: YAML設定にchoices_displayが見つかりません"
          else
            # enum値とYAML設定の整合性チェック
            enum_keys = enum_values.keys.map(&:to_s)
            yaml_keys = yaml_choices.keys.map(&:to_s)

            # enum定義にあるがYAMLにない値
            missing_in_yaml = enum_keys - yaml_keys
            unless missing_in_yaml.empty?
              errors << "#{model_class.name}##{enum_name}: YAML設定に不足している値: #{missing_in_yaml.join(', ')}"
            end

            # YAMLにあるがenum定義にない値
            extra_in_yaml = yaml_keys - enum_keys
            unless extra_in_yaml.empty?
              warnings << "#{model_class.name}##{enum_name}: YAML設定に余分な値: #{extra_in_yaml.join(', ')}"
            end

            # 完全一致の場合
            if missing_in_yaml.empty? && extra_in_yaml.empty?
              puts "    ✅ 整合性OK (#{enum_keys.size}個の値が一致)"
              yaml_choices.each do |key, display_name|
                puts "      #{key}: #{display_name}"
              end
            end
          end
        rescue StandardError => e
          errors << "#{model_class.name}##{enum_name}: YAML設定読み込みエラー - #{e.message}"
        end
      end
    end

    # 結果サマリー
    puts "\n=== 整合性チェック結果 ==="
    puts "検証対象: #{models_with_enums.size}個のモデル"

    if warnings.any?
      puts "\n⚠️  警告 (#{warnings.size}件):"
      warnings.each { |warning| puts "  - #{warning}" }
    end

    if errors.any?
      puts "\n❌ エラー (#{errors.size}件):"
      errors.each { |error| puts "  - #{error}" }
      exit 1
    else
      puts "\n✅ 整合性チェック完了: 問題ありません"
    end
  end

  desc 'YAML構文チェック'
  task validate_yaml_syntax: :environment do
    puts '=== YAML構文チェック開始 ==='

    validation_files = Rails.root.glob('config/validations/*.yml')
    errors = []

    if validation_files.empty?
      puts '⚠️  検証対象のYAMLファイルが見つかりません'
      return
    end

    validation_files.each do |file_path|
      file_name = File.basename(file_path)
      puts "#{file_name}を検証中..."

      begin
        content = YAML.load_file(file_path)

        if content.nil?
          errors << "#{file_name}: ファイルが空またはnullです"
        elsif !content.is_a?(Hash)
          errors << "#{file_name}: ルートレベルがハッシュではありません"
        else
          # 基本構造の検証
          model_name = File.basename(file_path, '.yml')

          if content.key?(model_name)
            model_config = content[model_name]
            if model_config.is_a?(Hash)
              puts "  ✅ 構文OK - #{model_config.keys.size}個の属性定義"

              # choices_displayセクションの検証
              choices_count = 0
              model_config.each_value do |attr_config|
                if attr_config.is_a?(Hash) && attr_config['choices_display']
                  choices_count += attr_config['choices_display'].size
                end
              end
              puts "  📋 選択肢表示名: #{choices_count}個" if choices_count.positive?
            else
              errors << "#{file_name}: モデル設定がハッシュではありません"
            end
          else
            errors << "#{file_name}: モデル名キー '#{model_name}' が見つかりません"
          end
        end
      rescue Psych::SyntaxError => e
        errors << "#{file_name}: YAML構文エラー - #{e.message}"
      rescue StandardError => e
        errors << "#{file_name}: 読み込みエラー - #{e.message}"
      end
    end

    # 結果サマリー
    puts "\n=== YAML構文チェック結果 ==="
    puts "検証対象: #{validation_files.size}個のファイル"

    if errors.any?
      puts "\n❌ エラー (#{errors.size}件):"
      errors.each { |error| puts "  - #{error}" }
      exit 1
    else
      puts "\n✅ 構文チェック完了: 問題ありません"
    end
  end

  desc '包括的チェック'
  task validate_all: %i[validate_yaml_syntax validate_consistency] do
    puts "\n🎉 全ての検証が完了しました！"
  end

  private

  # enum定義を持つモデルクラスを検索
  def find_models_with_enums
    models = []

    # app/modelsディレクトリ内のRubyファイルを検索
    model_files = Rails.root.glob('app/models/**/*.rb')

    model_files.each do |file_path|
      # ファイル名からクラス名を推測
      relative_path = file_path.sub(Rails.root.join('app/models/').to_s, '').sub('.rb', '')
      class_name = relative_path.camelize

      begin
        # クラスが存在し、ActiveRecordを継承している場合
        klass = class_name.constantize
        if klass.is_a?(Class) &&
           klass < ApplicationRecord &&
           klass.defined_enums.any?
          models << klass
        end
      rescue NameError
        # クラスが見つからない場合はスキップ
        next
      rescue StandardError => e
        puts "⚠️  #{class_name}の読み込みをスキップ: #{e.message}"
        next
      end
    end

    models.sort_by(&:name)
  end
end
