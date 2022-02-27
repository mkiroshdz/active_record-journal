module ActiveRecord
  module Journal
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

      module Base
        def journal_reads(**kwargs)
          prepare_journable_context!
          kwargs.merge!({journable: self, type: :reads})
          journable_context
            .add_rule(parse_journable_options(kwargs))
        end

        def journal_writes(**kwargs)
          prepare_journable_context!
          kwargs.merge!({journable: self, type: :writes})
          journable_context
            .add_rule(parse_journable_options(kwargs))
        end

        private

        def prepare_journable_context!
          return if @journable_context_prepared
          self.journable_context = Context.new(self)
          @journable_context_prepared = true
        end

        def parse_journable_options(kwargs)
          options = Options.new(**kwargs)
          options.check_type!
          options.check_actions!
          options
        end
      end
    end
  end
end