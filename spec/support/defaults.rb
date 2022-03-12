# frozen_string_literal: true

ActiveRecord::Journal.configuration.entries_class = 'JournalRecord'
ActiveRecord::Journal.configuration.tags_class = 'JournalTag'
