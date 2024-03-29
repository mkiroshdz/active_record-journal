# ActiveRecord::Journal

[![CircleCI](https://circleci.com/gh/mkiroshdz/active_record-journal/tree/main.svg?style=svg)](https://circleci.com/gh/mkiroshdz/active_record-journal/tree/main)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/3654af1924a941acb437adb133824ace)](https://www.codacy.com/gh/mkiroshdz/active_record-journal/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=mkiroshdz/active_record-journal&amp;utm_campaign=Badge_Grade)
[![Gem Version](https://badge.fury.io/rb/active_record-journal.svg)](https://badge.fury.io/rb/active_record-journal)

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

## Usage

Check the [wiki](https://github.com/mkiroshdz/active_record-journal/wiki/Index) for usage and configurations.

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
