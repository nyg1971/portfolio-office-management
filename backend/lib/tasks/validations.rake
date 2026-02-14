# frozen_string_literal: true

namespace :validations do
  desc 'enum-YAML整合性チェック'
  task validate_consistency: :environment do
    ValidationChecker.new.run_consistency_check
  rescue RuntimeError => e
    abort e.message
  end

  desc 'YAML構文チェック'
  task validate_yaml_syntax: :environment do
    ValidationChecker.new.run_yaml_syntax_check
  rescue RuntimeError => e
    abort e.message
  end

  desc '包括的チェック'
  task validate_all: %i[validate_yaml_syntax validate_consistency] do
    puts "\n🎉 全ての検証が完了しました！"
  end
end
