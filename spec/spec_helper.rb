require "bundler/setup"
require 'active_record'
require 'active_record/database_configurations'
require "active_record/journal"
require 'pry'

require_relative 'support/app_files_helper'
require_relative 'support/database_configuration_helper'

include AppFilesHelper
include DatabaseConfigurationHelper

ActiveRecord::Journal.configuration.entries_class = 'JournalRecord'
ActiveRecord::Journal.configuration.tags_class = 'JournalTag'

require_relative 'fixtures/models'

RSpec.configure do |config|
  config.before(:suite) do |ctx|
    schema_name = ctx.metadata[:schema] || 'postgresql'
    load_database_config
    configure_database_tasks
    load_database_schema(schema_name)
  end

  config.before(:example) do |example|
    init_params = example.metadata
    ActiveRecord::Journal.instance_variable_set('@configuration', nil)
    ActiveRecord::Journal.configuration.tap do |config|
      config.instance_variable_set('@entries_class', nil)
      config.instance_variable_set('@tags_class', nil)
      config.entries_class = init_params[:entries_class] || JournalRecord
      config.tags_class = init_params[:tags_class] || JournalTag
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
