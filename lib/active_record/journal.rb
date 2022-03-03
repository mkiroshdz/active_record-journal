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

      def with_tag(user: nil, description: nil)
        context = Journable::Context.new(user: user, description: description)
        yield context
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Journal.configuration.journables.each do |model_class|
    ActiveRecord::Journal::Journable.prepare(model_class)
  end
end

# Configuration: # automatic_recording (default true) / custom attribute comparison ex: html
# ActiveRecord::Journal::Task
  # install -> Generate migration and models.
  # prepare
# rake 

# ActiveRecord::Journal.with_tag(user: user, description: 'Comment', uuid: 'something') do
  # record_when(Book, :writes, with: options)
  # while_calling { actions_to_track }
# end

# ActiveRecord::Journal.ignore do
  # ignored actions here
# end

