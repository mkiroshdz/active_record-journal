ActiveRecord::Schema[7.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  
  create_table :books do |t|
    t.string :title, null: false
    t.string :isbn
    t.text :resume
    t.integer :year
    t.integer :publisher_id
  end

  create_table :book_authors do |t|
    t.integer :book_id
    t.integer :author_id
  end

  create_table :authors do |t|
    t.string :type
    t.string :name
    t.string :last_name
    t.date :birthday
    t.string :country
    t.integer :lock_version
  end

  create_table :publisher_companies do |t|
    t.string :name
    t.integer :cid
  end

  create_table :self_publishers do |t|
    t.integer :author_id
    t.string :name
    t.integer :ssn
  end

  create_table :journal_tags do |t|
    t.string :comment
    t.string :search_vector
    t.jsonb :journable_id
    t.datetime :created_at
  end

  create_table :journal_records do |t|
    t.jsonb :changes_map
    t.string :action
    t.string :journable_type
    t.integer :journable_id
    t.string :journal_tags_type
    t.integer :journal_tag_id
    t.string :user_type
    t.integer :user_id
    t.datetime :created_at
  end

  create_table :custom_journal_records do |t|
    t.jsonb :changes_map
    t.string :action
    t.string :journable_type
    t.integer :journable_id
    t.datetime :created_at
  end
end