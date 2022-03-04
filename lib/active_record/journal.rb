require 'active_record/journal/version'
require 'active_record/journal/constants'
require 'active_record/journal/configuration'
require 'active_record/journal/journable' 

module ActiveRecord
  module Journal    
    class Error < StandardError; end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def init
        yield configuration
      end

      def tag(**kwargs)
        context = Journable::Context.new(**kwargs)
        yield context
      end

      def context
        context = Journable::Context.new
        yield context
      end

      def ignore
        context = Journable::Context.new
        context.ignore_actions = true
        yield context
      end

      def context_override
        # https://ruby-doc.org/core-2.5.0/Thread.html#method-i-thread_variable_get
        Thread.current.thread_variable_get(:activerecord_journable_context_override)
      end

      def context_override=(context)
        # https://ruby-doc.org/core-2.5.0/Thread.html#method-i-thread_variable_set
        Thread.current.thread_variable_set(:activerecord_journable_context_override, context)
      end
    end
  end
end

# Send tag to if block 
  # Allow dynamic fields in tag 
  # Generate search vector (Value Object to be a value object)
  # Case when the actions raises an error. (Should reset the context_override)
  # interface for Journal.group, Journal.ignore, Journal.context
  # ActiveRecord::Journal::Task.install (migrations, generatos, models)
  # JournalRecord, JournalTag

