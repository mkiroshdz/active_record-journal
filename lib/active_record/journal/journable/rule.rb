require 'forwardable'

module ActiveRecord
  module Journal
    module Journable
      class Rule
        extend Forwardable
  
        ActiveRecord::Journal::JOURNABLE_OPTIONS.each do |option_name|
          def_delegator :@options, option_name, option_name
        end

        def_delegator :@options, :to_h, :to_h

        attr_reader :journable, :options
  
        def initialize(journable, options)
          @journable = journable
          @options = options
        end
  
        def conditions_met?(rec)
          return true unless self.if || self.unless
  
          assert_value = self.if ? true : false
          condition = self.if ? self.if : self.unless
          assert_condition(condition, rec, assert_value)
        end
  
        private
  
        def evaluate_condition(condition, rec)
          return condition.call(rec) if condition.respond_to?(:call)
          rec.send(condition)
        end
  
        def assert_condition(condition, rec, assert_value)
          !!evaluate_condition(condition, rec) == assert_value
        end
      end
    end
  end
end
