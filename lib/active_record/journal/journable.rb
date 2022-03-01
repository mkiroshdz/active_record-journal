require 'active_record/journal/journable/options'
require 'active_record/journal/journable/rule'
require 'active_record/journal/journable/context'

module ActiveRecord
  module Journal
    module Journable
      ##
      # Holds the methods used to configure the tracking of a particular model.
      # ---
      # = Example
      #   class Book < ActiveRecord::Base
      #     journal_reads **options
      #     journal_writes **options
      #   end

      module ClassMethods
        ##
        # Enable & configure the tracking of the read actions
        def journal_reads(**kwargs)
          prepare_journable_context!
          kwargs.merge!({journable: self, type: :reads})
          journable_context
            .add_rule(parse_journable_options(kwargs))
        end

        ##
        # Enable & configure the tracking of the writes, updates and destroy actions
        def journal_writes(**kwargs)
          prepare_journable_context!
          kwargs.merge!({journable: self, type: :writes})
          journable_context
            .add_rule(parse_journable_options(kwargs))
        end

        private

        def prepare_journable_context!
          return if @journable_context_prepared
          self.journable_context = Context.new(self)
          @journable_context_prepared = true
        end

        def parse_journable_options(kwargs)
          options = Options.new(**kwargs)
          options.check_type!
          options.check_actions!
          options
        end
      end

      def self.prepare(subject)
        subject.extend ClassMethods
        # Stores the model config and customization
        subject.class_attribute :journable_context
        # Callbacks
        subject.after_find callback_proc('read')
        subject.after_create callback_proc('create')
        subject.before_update callback_proc('update')
        subject.before_destroy callback_proc('destroy')
      end

      private

      def self.callback_proc(action)
        ->(record) { ActiveRecord::Journal::Record.create(subject: record, action: action) }
      end
    end
  end
end


