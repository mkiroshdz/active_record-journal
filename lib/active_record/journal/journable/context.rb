module ActiveRecord
  module Journal
    module Journable
      class Context
        attr_reader :user, :description

        Storage = Struct.new(*ActiveRecord::Journal::ACTIONS.values.flatten.map(&:to_sym), keyword_init: true) do
          def initialize
            actions = ActiveRecord::Journal::ACTIONS.values.flatten
            kwargs = actions.each_with_object({}) {|a, map| map[a.to_sym] = {} }
            super(**kwargs)
          end

          def add(action:, journable:, rule:)
            map = public_send(action)
            map[journable.model_name.to_s] ||= []
            map[journable.model_name.to_s] << rule
          end

          def search_by(action:, subject: nil)
            return unless map = public_send(action)
            return map.values.flatten if subject.nil?
            return unless key = map.keys.find {|name| subject.is_a?(name.constantize) }
            map[key]
          end
        end
  
        def initialize(user: nil, description: nil)
          @user = user
          @description = description
        end

        def configured_for?(action)
          rules.search_by(action: action.to_s)&.any? || false
        end

        def record_when(journable, type = nil, **with)
          options = ActiveRecord::Journal::Journable::Options.parse(with, type)
          rule = ActiveRecord::Journal::Journable::Rule.new(journable, options)
          options.on.each { |action| rules.add(action: action, journable: journable, rule: rule) }
        end

        def while_calling
          ActiveRecord::Journal::Record.context_override = self
          yield
          ActiveRecord::Journal::Record.context_override = nil
        end
        
        def rules
          @rules ||= Storage.new
        end

        def tag
          @tag ||= JournalTag.create!(user: user, description: description)
        end
      end
    end
  end
end
