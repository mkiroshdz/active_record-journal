ActiveRecord::Schema[7.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  
  create_table :books do |t|
    t.string :title, null: false
    t.string :isbn
  end

  create_table :journals do |t|
    t.integer :user_id
    t.string :user_type
    t.string :user_string
  end
end