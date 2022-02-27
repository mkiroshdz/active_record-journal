module ActiveRecord
  module Journal
    module Journable
      module Setup
        def self.call(klass)
          # Sets attribute to allocate options
          klass.class_attribute :journable_context

          # Adds methods to config journables
          klass.extend ActiveRecord::Journal::Journable::Base
          
          # Callbacks
          klass.after_find build_procedure('read')
          klass.after_create build_procedure('create')
          klass.before_update build_procedure('update')
          klass.before_destroy build_procedure('destroy')
        end

        private

        def self.build_procedure(action)
          ->(record) { ActiveRecord::Journal::Journable.track(record: record, action: action) }
        end
      end
    end
  end
end
