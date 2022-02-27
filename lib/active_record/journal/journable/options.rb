module ActiveRecord
  module Journal
    ACTIONS = { reads: %w[read], writes: %w[update create destroy] }.freeze
    JOURNABLE_OPTIONS = %i[journal on if unless only except journable type]
    
    def self.allowed_actions
      ActiveRecord::Journal::ACTIONS.values.flatten
    end

    module Journable
      class OptionError < StandardError; end

      Options = Struct.new(*ActiveRecord::Journal::JOURNABLE_OPTIONS, keyword_init: true) do
        def initialize(**kwargs)
          type = kwargs[:type].to_sym 
          kwargs[:type] = type
          kwargs[:journal] ||= config.journal
          kwargs[:on] = kwargs[:on]&.map(&:to_s) || ActiveRecord::Journal::ACTIONS[type]
          kwargs[:only] = kwargs[:only]&.map(&:to_s)
          kwargs[:except] = kwargs[:except]&.map(&:to_s)
          super(**kwargs)
        end

        def check_type!
          raise OptionError.new("#{type} actions are not allowed") if config.allowed_on.exclude?(type.to_s)
          self
        end

        def check_actions!
          on.each do |action|
            next if ActiveRecord::Journal.allowed_actions.include?(action)
            raise OptionError.new("#{action} is not a valid value for the on option") 
          end
        end

        private

        def config
          ActiveRecord::Journal.configuration
        end
      end
    end
  end
end
