# frozen_string_literal: true

module ActiveRecord
  module Journal
    module Journable
      class OptionError < StandardError; end

      Options = Struct.new(*ActiveRecord::Journal::JOURNABLE_OPTIONS, keyword_init: true) do
        def self.parse(kwargs, type)
          options = Options.new(**kwargs, type: type)
          options.check_actions!
          options
        end

        def initialize(**kwargs) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
          type = kwargs[:type].to_sym
          kwargs[:type] = type
          kwargs[:entries_class] ||= ActiveRecord::Journal.configuration.entries_class
          kwargs[:tags_class] ||= ActiveRecord::Journal.configuration.tags_class
          kwargs[:on] = kwargs[:on]&.map(&:to_s) || ActiveRecord::Journal::ACTIONS[type]
          kwargs[:only] = kwargs[:only]&.map(&:to_s)
          kwargs[:except] = kwargs[:except]&.map(&:to_s)
          super(**kwargs)
        end

        def check_actions!
          on.each do |action|
            next if ActiveRecord::Journal::ACTIONS[type.to_sym].include?(action)

            raise OptionError, "#{action} is not a valid value for the on option"
          end
        end
      end
    end
  end
end
