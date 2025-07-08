# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

# shoulda-matchers設定
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # factoryBot
  config.include FactoryBot::Syntax::Methods

  # データベースクリーナー
  # config.use_transactional_fixtures = true
  # データベーストランザクション（安全な書き方）
  config.use_transactional_fixtures = true if config.respond_to?(:use_transactional_fixtures)

  # JSON レスポンスヘルパー
  # config.include Devise::Test::IntegrationHelpers, type: :request

  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
  # Rails helpers
  # ファイルパスから自動でtype:を設定
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # 各テスト前後のクリーンアップ（トランザクションで解決しない場合の保険）
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation) if defined?(DatabaseCleaner)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction if defined?(DatabaseCleaner)
    DatabaseCleaner.start if defined?(DatabaseCleaner)
  end

  config.after(:each) do
    DatabaseCleaner.clean if defined?(DatabaseCleaner)
  end
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
