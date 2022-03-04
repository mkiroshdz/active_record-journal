# ActiveRecord::Journal

'ActiveRecord::Journal' allows you to keep track of the CRUDs on your 'ActiveRecord' models, as well as groups of operations tagged with data (ex: the user or job that triggered the actions, description, ...).

This gem works rails applications and standalone usages of the active record module.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record-journal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record-journal


## Usage

### Journal Models

The gem data will be handled by two models that you will define

```ruby
  class BookStoreJournal < ActiveRecord::Journal::Record; end
  class BookStoreJournalTag < ActiveRecord::Journal::Tag; end
```

The models that inherit from 'ActiveRecord::Journal::Record' will keep track of the cruds.
The models that inherit from 'ActiveRecord::Journal::Tag' will group those records and add some data for context.

### Initial configuration

```ruby
  ActiveRecord::Journal.configuration.entries_class = BookStoreJournal
  ActiveRecord::Journal.configuration.tag = BookStoreJournalTag
```

### Extend Journable Interface

This will provide the required methods to enable tracking in the models.

```ruby
  class JournableRecord < ActiveRecord::Base
    extend ActiveRecord::Journal::Journable
  end
```

### Model tracking

```ruby
  class Author < JournableRecord   
    journal_reads # Enables/Configures reads tracking
  end

  class Book < JournableRecord    
    belongs_to :author
    journal_writes # Enables/Configures writes tracking
  end
```

### Group operations

The records created by multiple cruds can be grouped.

```ruby
  ActiveRecord::Journal.tag(user: current_user) do
    actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end
```

### Ignore operations

Can ignore actions originally configured to be tracked.

```ruby
  ActiveRecord::Journal.ignore do
    actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end
```

### One time constraints

```ruby
  ActiveRecord::Journal.tag(user: current_user) do
    record(Book, if: ->(record) { record.author.present? })
    actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end

  ActiveRecord::Journal.context do
    record(Book, if: ->(record) { record.author.present? })
    actions do
      author = Author.find_by(id: params[:author_id])
      Book.create!(title: params[:title], author: author)
    end
  end
```

## Development

After checking out the repo, you can build the required containers by running `docker-compose build` and execute them with `docker-compose run gem`.

Inside the container, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mkiroshdz/active_record-journal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveRecord::Journal project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_record-journal/blob/master/CODE_OF_CONDUCT.md).
