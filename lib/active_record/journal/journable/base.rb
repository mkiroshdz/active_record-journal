module ActiveRecord
  module Journal
    ACTIONS = { reads: %w[read], writes: %w[update create destroy] }.freeze
    JOURNABLE_OPTIONS = %i[journal on if unless only except journable type]
    
    module Record
      def self.track(record:, action:)
        model = record.class
        return unless model.journable_context&.configured_for?(action)

        model.journable_context.each_rule(action: action, record: record) do |rule|
          attributes = rule.attributes(record.class)
          changes = Changes.new(record, action, attributes).call
          rule.journal.create!(entry_changes: changes, journable: record, action: action) if action == 'read' || changes.any?
        end
      end
    end

    module Journable
      def self.track(record:, action:)
        model = record.class
        return unless model.journable_context&.configured_for?(action)

        model.journable_context.each_rule(action: action, record: record) do |rule|
          attributes = rule.attributes(record.class)
          changes = Changes.new(record, action, attributes).call
          rule.journal.create!(entry_changes: changes, journable: record, action: action) if action == 'read' || changes.any?
        end
      end
    end
  end
end