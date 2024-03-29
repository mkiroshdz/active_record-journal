# frozen_string_literal: true

module DatabaseSetup
  # https://github.com/rails/rails/blob/75a9e1be75769ae633a938d81d51e06852a69ea3/activerecord/lib/active_record/database_configurations.rb
  FIXTURES_PATH = 'spec/fixtures'

  def self.restore_schema!(name)
    load_database_config(name)
    configure_database_tasks
    load_database_schema(name)
  end

  def self.trucante_database_tables
    ActiveRecord::Tasks::DatabaseTasks.truncate_all
  end

  def self.project_root
    @project_root ||= ENV['RAILS_RELATIVE_URL_ROOT']
  end

  def self.load_database_config(name)
    return if defined?(@yaml_database_config)

    database_config_path = File.expand_path("#{FIXTURES_PATH}/config/#{name}.yml", project_root)
    @yaml_database_config = YAML.safe_load(ERB.new(File.read(database_config_path)).result)
    ActiveRecord::Base.configurations = ActiveRecord::DatabaseConfigurations.new(@yaml_database_config)
  end

  # https://github.com/rails/rails/blob/59eb7edb687c8b9cffc74288921b77da01971fb2/activerecord/lib/active_record/tasks/database_tasks.rb

  def self.load_database_schema(schema_version)
    return if @schema_version == schema_version

    @schema_version = schema_version
    schema_path = File.expand_path("#{FIXTURES_PATH}/db/schemas/#{@schema_version}.rb", project_root)
    ActiveRecord::Tasks::DatabaseTasks.drop_current
    ActiveRecord::Tasks::DatabaseTasks.create_current
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, schema_path)
  end

  def self.configure_database_tasks
    ActiveRecord::Tasks::DatabaseTasks::LOCAL_HOSTS << ENV['POSTGRES_HOST_NAME']
    ActiveRecord::Tasks::DatabaseTasks.root = project_root
    ActiveRecord::Tasks::DatabaseTasks.env = ENV['RAILS_ENV']
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path('db', project_root)
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [File.expand_path('db/migrate', project_root)]
  end
end
