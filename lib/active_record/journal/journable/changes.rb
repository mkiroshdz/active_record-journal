# frozen_string_literal: true

module ActiveRecord
  module Journal
    module Journable
      Changes = Struct.new(:subject, :action, :keys, :mask_keys) do
        def call
          changes.each_with_object({}) do |(key, value), attrs|
            attrs[key] = value
            next unless mask_keys&.include?(key)

            attrs[key] = value.is_a?(Array) ? [nil, nil] : nil
          end
        end

        private

        def changes
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

        def destroy_diff
          subject.attributes.select { |k, v| keys.include?(k) && v.present? }
        end

        def non_persisted_diff
          diff.select { |k, v| keys.include?(k) && v.last.present? }
        end

        def persisted_diff
          diff.select { |k, _v| keys.include?(k) }
        end

        def diff
          subject.changes.any? ? subject.changes : subject.previous_changes
        end
      end
    end
  end
end
