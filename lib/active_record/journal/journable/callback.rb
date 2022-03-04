module ActiveRecord
  module Journal
    module Journable
      class Callback
        attr_reader :action

        def initialize(action)
          @action ||= action
        end

        def to_proc
          callback = self
          ->(record) { callback.call(record) }
        end

        def call(record)
          return unless valid_context?
          
          override = rules_for(context: context_override, record: record) || {}
          rules = rules_for(context: record.class.journable_context, record: record)

          rules&.each do |journal, list|
            list.each do |rule|
              next unless rules_met?(rule: rule, override: override[journal], record: record)
              attributes = Attributes.new(record, rule).tracked_keys
              changes = Changes.new(record, action, attributes).call
              record_changes(changes: changes, record: record, journal: rule.journal)
            end
          end
        end

        private

        def record_changes(journal:, changes:, record:)
          return unless action == 'read' || changes.any?
          journal.create!(changes_map: changes, journable: record, journal_tag: context_override&.tag, action: action)
        end

        def rules_met?(rule:, override:, record:)
          rule.conditions_met?(record) && 
            (override.nil? || override.all? { _1.conditions_met?(record) })
        end

        def rules_for(context:, record:)
          context
            &.rules
            &.search_by(action: action, subject: record)
            &.group_by {|r| r.journal.model_name.param_key }
        end

        def valid_context?
          (configuration.autorecording_enabled || context_override) &&  !!context_override&.ignore_actions == false
        end

        def context_override
          ActiveRecord::Journal.context_override
        end

        def configuration
          ActiveRecord::Journal.configuration
        end
      end
    end
  end
end
