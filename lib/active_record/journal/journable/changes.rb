module ActiveRecord
  module Journal
    module Journable
      class Changes
        ACTIONS = %w[read destroy create update].freeze
  
        attr_reader :record, :action, :attributes
  
        def initialize(record, action, attributes)
          @record = record
          @action = action
          @attributes = attributes
        end

        def call
          case action
          when 'create'
            initial_values
          when 'update'
            saved_changes
          when 'destroy'
            latest_attributes
          else
            {}
          end
        end

        private
  
        def latest_attributes
          record
            .attributes
            .slice(*attributes)
        end
  
        def initial_values
          {}.tap do |values|
            latest_attributes.each do |name, val|
              next unless attributes.include?(name) && val.presence
              values[name] = [nil, val]
            end
          end
        end
  
        def saved_changes
          changes = record.changes.any? ? record.changes : record.previous_changes
          {}.tap do |values|
            changes.each do |name, (old_value, new_value)|
              next unless attributes.include?(name) && old_value.presence != new_value.presence
              values[name] = [old_value, new_value]
            end
          end
        end
      end
    end
  end
end
