# frozen_string_literal: true

class JournalRecord < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
  belongs_to :journal_tag, polymorphic: true
  belongs_to :user, polymorphic: true
end

class JournalTag < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
  belongs_to :user, polymorphic: true
end

class CustomJournalRecord < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
end

module Fixtures
  class AppRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  class JournableAppRecord < ActiveRecord::Base
    extend ActiveRecord::Journal::Journable

    self.abstract_class = true
  end

  class Anonymous < ActiveRecord::Base
    extend ActiveRecord::Journal::Journable

    self.abstract_class = true
    def self.model_name
      ActiveModel::Name.new(self, Fixtures, 'Fixtures::Anonymous')
    end
  end

  class User < JournableAppRecord; end

  class Publisher < JournableAppRecord
    self.abstract_class = true
    journal_reads
    journal_writes
  end

  class SelfPublisher < Publisher; end

  # STI
  class Author < JournableAppRecord
    has_many :journal_records, as: :journable
    journal_writes
  end

  class GuestAuthor < Author
    has_many :journal_records, as: :journable
    journal_reads
  end

  class OriginalAuthor < Author; end

  class Book < JournableAppRecord
    has_many :custom_journal_records, as: :journable
    journal_reads(entries_class: CustomJournalRecord)
  end

  class BookAuthor < JournableAppRecord
    belongs_to :author
    journal_reads(entries_class: CustomJournalRecord, if: :guest?)
    journal_writes(on: %i[create], only: %i[book_id], unless: :without_author?)
    journal_writes(on: %i[update], except: %i[author_id], if: :with_author?)
    journal_writes(on: %i[destroy], only: [])

    def with_author?
      !author_id.nil?
    end

    def without_author?
      author_id.nil?
    end
  end
end
