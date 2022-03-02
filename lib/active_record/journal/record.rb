require_relative 'record/attributes'
require_relative 'record/changes'

module ActiveRecord
  module Journal
    module Record

      # https://ruby-doc.org/core-2.5.0/Thread.html#method-c-current 

      def self.context_override
        Thread.current.thread_variable_get(:activerecord_journal_context_override)
      end

      def self.context_override=(context)
        Thread.current.thread_variable_set(:activerecord_journal_context_override, context)
      end

      def self.create(subject:, action:)
        default_rules = rules_for(context: subject.journable_context, action: action, subject: subject) || {}
        override_rules = rules_for(context: context_override, action: action, subject: subject) || {}

        default_rules.each do |journal, list|
          list.each do |rule|
            next unless rule.conditions_met?(subject)
            next unless override_rules[journal].nil? || override_rules[journal].all? { _1.conditions_met?(subject) }
            attributes = Attributes.new(subject, rule)
            changes = Changes.new(subject, action, attributes.tracked_keys).call
            next unless action == 'read' || changes.any?
            rule.journal.create!(changes_map: changes, journable: subject, action: action)
          end
        end
      end

      def self.rules_for(context:, action:, subject:)
        context
          &.rules
          &.search_by(action: action, subject: subject)
          &.group_by {|r| r.journal.model_name.param_key }
      end
    end
  end
end