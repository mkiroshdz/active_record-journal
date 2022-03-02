class JournalRecord < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
end
class CustomJournalRecord < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
end

class Anonymous < ActiveRecord::Base
  self.abstract_class = true
  def self.model_name
    ActiveModel::Name.new(self, Fixtures, 'Anonymous')
  end
end

module Fixtures
  class AppRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  class Publisher < AppRecord
    self.abstract_class = true
    journal_reads 
    journal_writes
  end
  class SelfPublisher < Publisher; end

  # STI
  class Author < AppRecord
    has_many :journal_records, as: :journable
    journal_writes
  end
  class GuestAuthor < Author
    has_many :journal_records, as: :journable
    journal_reads
  end
  class OriginalAuthor < Author; end

  class Book < AppRecord    
    has_many :custom_journal_records, as: :journable
    journal_reads(journal: CustomJournalRecord)
  end

  class BookAuthor < AppRecord
    belongs_to :author
    journal_reads(journal: CustomJournalRecord, if: :guest?)
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