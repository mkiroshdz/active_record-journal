module Fixtures
  class AppRecord < ActiveRecord::Base
    self.abstract_class = true
  end
  class CustomJournal < AppRecord
    self.table_name = 'journals'
  end
  class Book < AppRecord; end
  class Journal < AppRecord; end
end
Journal = Fixtures::Journal