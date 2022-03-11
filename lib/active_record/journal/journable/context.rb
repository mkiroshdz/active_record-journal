# frozen_string_literal: true

module ActiveRecord
  module Journal
    module Journable
      class Context
        attr_writer :ignore_actions, :generate_tag

        Storage = Struct.new(*ActiveRecord::Journal::ACTIONS.values.flatten.map(&:to_sym), keyword_init: true) do
          def initialize
            actions = ActiveRecord::Journal::ACTIONS.values.flatten
            kwargs = actions.each_with_object({}) { |a, map| map[a.to_sym] = {} }
            super(**kwargs)
          end

          def add(action:, journable:, rule:)
            map = public_send(action)
            map[journable.model_name.to_s] ||= []
            map[journable.model_name.to_s] << rule
          end

          def search_by(action:, subject: nil)
            map = public_send(action)
            return unless map

            return map.values.flatten if subject.nil?

            key = map.keys.find { |name| subject.is_a?(name.constantize) }
            return unless key

            map[key]
          end
        end

        def initialize(**tags_args)
          @tags_args = tags_args
        end

        def configured_for?(action)
          rules.search_by(action: action.to_s)&.any? || false
        end

        def record(journable, type = nil, **with)
          options = ActiveRecord::Journal::Journable::Options.parse(with, type)
          rule = ActiveRecord::Journal::Journable::Rule.new(journable, options)
          options.on.each { |action| rules.add(action: action, journable: journable, rule: rule) }
        end

        def actions
          ActiveRecord::Journal.context_override = self
          yield
          ActiveRecord::Journal.context_override = nil
        rescue StandardError
          ActiveRecord::Journal.context_override = nil
        end

        def ignore_actions
          @ignore_actions || false
        end

        def generate_tag
          @generate_tag || false
        end

        def rules
          @rules ||= Storage.new
        end

        def tag(tags_class)
          return @tag if defined?(@tag)

          @tag = tags_class.create!(**@tags_args) if generate_tag
        end
      end
    end
  end
end
