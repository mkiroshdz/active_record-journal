[![CircleCI](https://circleci.com/gh/mkiroshdz/active_record-journal/tree/main.svg?style=svg)](https://circleci.com/gh/mkiroshdz/active_record-journal/tree/main)

# ActiveRecord::Journal

ActiveRecord::Journal allows you to keep track of the CRUDs on your ActiveRecord models and tag them with the data of your choice (the user or job that triggered the actions, description, ...).

## Getting started

Add this line to your application's Gemfile:

```ruby
gem 'active_record-journal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record-journal


## Setup

### Initialization

```ruby
  ActiveRecord::Journal.configuration.entries_class = 'BookChangeLog'
  ActiveRecord::Journal.configuration.tags_class = 'BookChangeTag'
  ActiveRecord::Journal.configuration.autorecording_enabled = true
```

### Logs

You need to define the models that will persist the records and tags of the CRUDs.

```ruby
  class BookChangeLog < ActiveRecord::Base; end
  class BookChangeTag < ActiveRecord::Base; end
```

The minimun attributes required for the models are shown in this schema: 

```ruby
  create_table :book_change_logs do |t| # Table for the records
    # t.string :changes_map 
    t.jsonb :changes_map
    t.string :action
    t.string :journable_type
    t.integer :journable_id
    t.string :journal_tag_type
    t.integer :journal_tag_id
    t.datetime :created_at
  end

  create_table :book_change_tags do |t| # Table for the tags
    t.string :journable_type
    t.integer :journable_id
    t.datetime :created_at
  end
```

Note: The gem assumes that the `BookChangeLog#changes_map=` receives a hash and the logic to handle the serialization will be handled by the model regardless of the type of changes_map in the database.

### Extend ActiveRecord::Base

This will provide the required methods to enable tracking in the models.

```ruby
  class RecordWithLogs < ActiveRecord::Base
    self.abstract_class = true
    extend ActiveRecord::Journal::Journable
  end
```

### Model tracking

You can use the methods `ActiveRecord::Journal::Journable::journal_writes` and `ActiveRecord::Journal::Journable::journal_reads` to define a set of rules that tell your model how to keep track of the records. Every time a CRUD is triggered all the rules defined are checked and executed if the necessary conditions are met.

```ruby
  class Author < RecordWithLogs   
    journal_writes on: %i[create]
    journal_writes on: %i[update], only: %i[name last_name]
  end

  class Book < RecordWithLogs    
    belongs_to :author
    journal_reads unless: :best_seller?
    journal_reads entries_class: CustomBookChangeLog, tag_class: BookChangeTag, if: :best_seller?
    journal_writes
  end
```

## Usage

### Tag operations

You can create and associate a tag to a group of CRUDS.

```ruby
  ActiveRecord::Journal.tag(user: current_user, description: 'Create book') do |tag|
    tag.actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end
```

### Ignore operations

Can ignore actions originally configured to be tracked.

```ruby
  ActiveRecord::Journal.ignore do |context|
    context.actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end
```

### One time constraints

```ruby
  ActiveRecord::Journal.tag(user: current_user) do |tag|
    tag.record(Book, if: ->(record) { record.author.present? })
    tag.actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end

  ActiveRecord::Journal.context do |context|
    context.record(Book, unless: ->(record) { record.author.present? })
    context.actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end
```

## Development

### Setup

After checking out the repo, you can build the required containers by running `docker-compose build` and execute them with `docker-compose run gem`.

To install this gem onto your local, run `bundle exec rake install`. 

### Tests

Inside the container, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mkiroshdz/active_record-journal.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
