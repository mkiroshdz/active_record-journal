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

class CustomJournalTag < ActiveRecord::Base
  belongs_to :journable, polymorphic: true
end
