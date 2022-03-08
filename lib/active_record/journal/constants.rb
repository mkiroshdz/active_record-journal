# frozen_string_literal: true

module ActiveRecord
  module Journal
    ACTIONS = { reads: %w[read], writes: %w[update create destroy] }.freeze
    JOURNABLE_OPTIONS = %i[entries_class tags_class on if unless only except type].freeze
  end
end
