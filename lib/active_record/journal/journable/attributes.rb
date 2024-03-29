# frozen_string_literal: true

module ActiveRecord
  module Journal
    module Journable
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
          [
            model.primary_key,
            model.inheritance_column,
            model.locking_column,
            'created_at',
            'updated_at'
          ].compact.map(&:to_s)
        end
      end
    end
  end
end
