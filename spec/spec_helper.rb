require "bundler/setup"
require 'active_record'
require 'active_record/database_configurations'
require "active_record/journal"
require 'pry'

require_relative 'fixtures/models'
require_relative 'support/app_files_helper'
require_relative 'support/database_configuration_helper'

include AppFilesHelper
include DatabaseConfigurationHelper

RSpec.configure do |config|
  config.before(:suite) do |ctx|
    schema_name = ctx.metadata[:schema] || 'postgresql'
    load_database_config
    configure_database_tasks
    load_database_schema(schema_name)
  end

  config.before(:example) do |example|
    init_params = example.metadata[:init_params] || {}
    ActiveRecord::Journal.instance_variable_set('@configuration', nil)
    ActiveRecord::Journal.init do |config|
      config.journal_class_name = init_params[:journal_class_name] if init_params[:journal_class_name]
      config.journable_class_names = init_params[:journable_class_names] if init_params[:journable_class_names]
      config.allowed_on = init_params[:allowed_on] if init_params[:allowed_on]
      config.autorecording_enabled = init_params[:autorecording_enabled]
    end
    trucante_database_tables
  end

  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
