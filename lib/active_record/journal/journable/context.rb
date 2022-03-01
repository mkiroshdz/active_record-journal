module ActiveRecord
  module Journal
    module Journable
      class Context
        attr_reader :journable, :rules
  
        def initialize(journable)
          @journable = journable
        end
  
        def add_rule(options)
          rule = ActiveRecord::Journal::Journable::Rule.new(options)
          options.on.each {|action| rules[action].push(rule) }
        end

        def configured_for?(action)
          rules[action.to_s]&.any? || false
        end

        def rules_store
          @rules ||= {}.tap do |rls|
            ActiveRecord::Journal::ACTIONS.values.flatten.each do |action| 
              rls[action.to_s] = []
            end
          end
        end
        alias rules rules_store
      end
    end
  end
end
