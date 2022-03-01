require_relative 'record/attributes'
require_relative 'record/changes'

module ActiveRecord
  module Journal    
    module Record
      def self.create(subject:, action:)
        model = subject.class
        context = subject.journable_context
        return unless context&.configured_for?(action)

        context.rules[action.to_s].each do |rule|
          next unless rule.conditions_met?(subject)
          attributes = Attributes.new(subject, rule)
          changes = Changes.new(subject, action, attributes.tracked_keys).call
          next unless action == 'read' || changes.any?
          rule.journal.create!(changes_map: changes, journable: subject, action: action)
        end
      end
    end
  end
end