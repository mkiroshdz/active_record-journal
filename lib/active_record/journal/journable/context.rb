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
          rules[action.to_s]&.any?
        end

        def each_rule(action:, record: nil, &blk)
          rules[action.to_s].each do |r|
            next unless record.nil? || r.conditions_met?(record)
            blk.call(r)
          end
        end

        def rules
          @rules ||= {}.tap do |rls|
            ActiveRecord::Journal.allowed_actions.each do |action| 
              rls[action.to_s] = []
            end
          end
        end
      end
    end
  end
end
