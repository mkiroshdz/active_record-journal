require_relative 'journable/options'
require_relative 'journable/rule'
require_relative 'journable/context'
require_relative 'journable/attributes'
require_relative 'journable/changes'
require_relative 'journable/callback'

module ActiveRecord
  module Journal
    module Journable
      def self.extended(subject)
        subject.class_attribute :journable_context 

        subject.after_find &Callback.new('read')
        subject.after_create &Callback.new('create')
        subject.before_update &Callback.new('update')
        subject.before_destroy &Callback.new('destroy')
      end

      ##
      # Enable & configure the tracking of the read actions
      def journal_reads(**kwargs)
        init_journable_context
        journable_context.record(self, :reads, **kwargs)
      end

      ##
      # Enable & configure the tracking of the writes, updates and destroy actions
      def journal_writes(**kwargs)
        init_journable_context
        journable_context.record(self, :writes, **kwargs)
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


