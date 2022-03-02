require_relative 'journable/options'
require_relative 'journable/rule'
require_relative 'journable/context'

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
          init_journable_context
          journable_context.record_when(self, :reads, **kwargs)
        end

        ##
        # Enable & configure the tracking of the writes, updates and destroy actions
        def journal_writes(**kwargs)
          init_journable_context
          journable_context.record_when(self, :writes, **kwargs)
        end

        private

        def init_journable_context
          return if @init_journable_context
          self.journable_context = Context.new
          @init_journable_context = true
        end
      end

      ##
      # Add configuration methods available to the journable models.
      def self.prepare(subject)
        subject.extend ClassMethods

        # Setup configuration storage
        subject.class_attribute :journable_context 

        # Setup Callbacks
        subject.after_find callback_procedure_for('read')
        subject.after_create callback_procedure_for('create')
        subject.before_update callback_procedure_for('update')
        subject.before_destroy callback_procedure_for('destroy')
      end

      private

      def self.callback_procedure_for(action)
        ->(record) { ActiveRecord::Journal::Record.create(subject: record, action: action) }
      end
    end
  end
end


