module ActiveRecord
  module Journal    
    module Record
      Attributes = Struct.new(:subject, :rule) do
        def model
          subject.class
        end

        def tracked_keys
          keys - ignored_keys
        end

        def ignored_keys
          if rule.only
            (keys - rule.only) | default_ignored_keys
          elsif rule.except
            default_ignored_keys | rule.except
          else
            default_ignored_keys
          end
        end

        def keys
          model.column_names.map(&:to_s)
        end

        def default_ignored_keys
          [ model.primary_key, model.inheritance_column, model.locking_column ]
        end
      end

      Changes = Struct.new(:subject, :action, :keys) do
        def call
          case action
          when 'create'
            non_persisted_diff
          when 'update'
            persisted_diff
          when 'destroy'
            destroy_diff
          else
            none
          end
        end

        def none
          {}
        end

        private

        def destroy_diff
          subject.attributes.select {|k, v| keys.include?(k) && v.present? }
        end

        def non_persisted_diff
          diff.select {|k, v| keys.include?(k) && v.last.present? }
        end

        def persisted_diff
          diff.select {|k, v| keys.include?(k) }
        end

        def diff
          subject.changes.any? ? subject.changes : subject.previous_changes
        end
      end

      def self.create(subject:, action:)
        model = subject.class
        context = subject.journable_context
        return unless context&.configured_for?(action)

        context.rules[action.to_s].each do |rule|
          next unless rule.conditions_met?(subject)
          attributes = Attributes.new(subject, rule)
          changes = Changes.new(subject, action, attributes.tracked_keys).call
          next unless action == 'read' || changes.any?
          rule.journal.create!(entry_changes: changes, journable: subject, action: action)
        end
      end
    end
  end
end