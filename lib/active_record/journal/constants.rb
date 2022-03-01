module ActiveRecord
  module Journal
    ACTIONS = { reads: %w[read], writes: %w[update create destroy] }.freeze
    JOURNABLE_OPTIONS = %i[journal on if unless only except journable type]
  end
end