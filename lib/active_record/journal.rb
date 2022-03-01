require 'active_record/journal/version'
require 'active_record/journal/constants'
require 'active_record/journal/configuration'
require 'active_record/journal/record'
require 'active_record/journal/journable' 

module ActiveRecord
  module Journal
    ACTIONS = { reads: %w[read], writes: %w[update create destroy] }.freeze
    JOURNABLE_OPTIONS = %i[journal on if unless only except journable type]
    
    class Error < StandardError; end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def init
        yield configuration
      end

      def allowed_actions
        ActiveRecord::Journal::ACTIONS.values.flatten
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Journal.configuration.journables.each do |model_class|
    ActiveRecord::Journal::Journable.prepare(model_class)
  end
end

# ActiveRecord::Journal.log(responsable: user, description: 'Comment') do
#   context do / Uses default context if not defined
  #   track_writes/track_reads(
  #     journal: Audits,
  #     actions: [:create, :update, :delete],
  #     if: ->(record) { check }, 
  #     unless: ->(record) { check } ) -> Context
  #  track { Actions to log }
  #  ignore { Actions not logged }
# end
# end
