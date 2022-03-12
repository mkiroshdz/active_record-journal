# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'simplecov'
require 'support/simplecov'
require 'active_record'
require 'active_record/journal'
require 'support/defaults'
require 'support/database_setup'
require 'support/configuration_setup'

schema = ENV['DB_CONFIG'] || 'postgresql'

require "fixtures/models/#{schema}"
require 'fixtures/models/shared'

RSpec.configure do |config|
  config.before(:suite) do |_ctx|
    DatabaseSetup.restore_schema!(schema)
  end

  config.before(:example) do |example|
    ConfigurationSetup.clear!
    ConfigurationSetup.init(example.metadata)
    DatabaseSetup.trucante_database_tables
  end

  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
