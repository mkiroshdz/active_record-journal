require_relative 'journable/options'
require_relative 'journable/rule'
require_relative 'journable/context'

module ActiveRecord
  module Journal
    module Journable
      def self.extended(subject)
        subject.class_attribute :journable_context 
        factory = ActiveRecord::Journal::Record

        subject.after_find ->(record) { factory.create(subject: record, action: 'read') }
        subject.after_create ->(record) { factory.create(subject: record, action: 'create') }
        subject.before_update ->(record) { factory.create(subject: record, action: 'update') }
        subject.before_destroy ->(record) { factory.create(subject: record, action: 'destroy') }
      end

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
  end
end


