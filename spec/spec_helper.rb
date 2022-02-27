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
  config.add_setting :schema, default: 'version_1'
  config.before(:suite) do 
    load_database_config
    configure_database_tasks
  end
  config.before(:all) { load_database_schema(RSpec.configuration.schema) }
  config.before(:example) { trucante_database_tables }
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
