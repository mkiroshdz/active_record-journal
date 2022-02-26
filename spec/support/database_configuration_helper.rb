

module DatabaseConfigurationHelper
  # https://github.com/rails/rails/blob/75a9e1be75769ae633a938d81d51e06852a69ea3/activerecord/lib/active_record/database_configurations.rb

  def load_database_config
    return if defined?(@yaml_database_config)
  
    database_config_path = File.expand_path('config/database.yml', app_root)
    @yaml_database_config = YAML.load(ERB.new(File.read(database_config_path)).result)
    ActiveRecord::Base.configurations = ActiveRecord::DatabaseConfigurations.new(@yaml_database_config)
  end

  # https://github.com/rails/rails/blob/59eb7edb687c8b9cffc74288921b77da01971fb2/activerecord/lib/active_record/tasks/database_tasks.rb
  
  def load_database_schema(schema_version)
    return if @schema_version == schema_version

    @schema_version = schema_version
    schema_path = File.expand_path("db/schemas/#{@schema_version}.rb", app_root)
    ActiveRecord::Tasks::DatabaseTasks.drop_current
    ActiveRecord::Tasks::DatabaseTasks.create_current
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, schema_path)
  end

  private

  def configure_database_tasks
    ActiveRecord::Tasks::DatabaseTasks::LOCAL_HOSTS << ENV['POSTGRES_HOST_NAME']
    ActiveRecord::Tasks::DatabaseTasks.root = app_root
    ActiveRecord::Tasks::DatabaseTasks.env = ENV['RAILS_ENV']
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path('db', app_root)
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [File.expand_path('db/migrate', app_root)]
  end
end