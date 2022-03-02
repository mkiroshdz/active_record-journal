require 'active_record/journal/version'
require 'active_record/journal/constants'
require 'active_record/journal/configuration'
require 'active_record/journal/record'
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

      def tagged_with(user:, description: nil)
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Journal.configuration.journables.each do |model_class|
    ActiveRecord::Journal::Journable.prepare(model_class)
  end
end

# def self.callback_context
#   Thread.current.thread_variable_get(:activerecord_journal_callback_context)
# end

# def self.callback_context=(context)
#   Thread.current.thread_variable_set(:activerecord_journal_callback_context, context)
# end

# Configuration: # automatic_recording (default true)
# record::context 
  # (journal_writes/journal_reads -> configurable?)
  # 
# ActiveRecord::Journal.tagged_with(responsable: user, comment: 'Comment') do
  # record(Book, :writes, with: options)
  # override_journal_reads(Book, options)
  # ignore_journal_reads(Book, options)
  # ignore_journal_writes(Book, options)
  # record { actions_to_track }
  # builds journable context (dup & override)
  # Thread.current.thread_variable_set(:_activerecord_journal_cbk_context)
  # https://ruby-doc.org/core-2.5.0/Thread.html#method-c-current 
  # Executes callback procedure the wrapper (context is now a param)
# end

  # ActiveRecord::Journal.ignore do
    # ignored actions here
  # end
# end
