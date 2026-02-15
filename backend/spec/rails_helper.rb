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
  # TimeHelpers
  config.include ActiveSupport::Testing::TimeHelpers

  # factoryBot
  config.include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = true

  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
