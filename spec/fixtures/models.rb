module Fixtures
  class Book < ActiveRecord::Base; end
  class Journal < ActiveRecord::Base; end
  class CustomJournal < ActiveRecord::Base
    self.table_name = 'journals'
  end
end
Journal = Fixtures::Journal