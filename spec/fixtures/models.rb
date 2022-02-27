class Journal < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
end
class CustomJournal < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
end

module Fixtures
  class AppRecord < ActiveRecord::Base
    self.abstract_class = true
  end
  class Book < AppRecord    
    has_many :custom_journals, as: :journable
    journal_reads(journal: CustomJournal)
  end
  class Author < AppRecord
    has_many :journals, as: :journable
    journal_writes
  end
  class GuestAuthor < Author
    has_many :journals, as: :journable
    journal_reads
  end
  class OriginalAuthor < Author; end
  class BookAuthor < AppRecord
    belongs_to :author
    journal_reads(journal: CustomJournal, if: :guest?)
    journal_writes(on: %i[create], only: %i[book_id], unless: :guest?)
    journal_writes(on: %i[update], except: %i[author_id], if: :guest?)
    journal_writes(on: %i[destroy], only: [])
    
    def guest?
      author.is_a?(GuestAuthor)
    end
  end
end