require "active_record/journal/version"
require "active_record/journal/configuration"

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
    end
    # ActiveSupport.on_load(:active_record) { }
  end
end

# ::ActiveRecord::Journal::Version / has one versionable (Polymorphic)
  # Defines what a new version is
  # Compares versions
  # Hashes versions

# ::ActiveRecord::Journal::Log / has many entries / has responsable
  # Defines a responsable for the entry (User/Process)
  # Packs and timelines multiple Items (Reads/Writes/Description for all of them)
  # References final and initial versions
  # has action: [:create, :update, :delete] | [:index, :search]

# ::ActiveRecord::Journal::Entry (Read / Write) /  (Responsable, Read/Write, Comment, Models Version Hash (Initial/Final))
  # has versions (Initial / Final)
  # has model (Polymorphic)

# ::ActiveRecord::Journal::Configuration
  # Initial setup of the gem

# ::ActiveRecord::Journal::Options
  # Options for contexts

# ::ActiveRecord::Journal::Context / Log
  # Customization of options and exceptions

# General Use
# default excluded:
  # %i[id primary_key inheritance_column locking_column]
# options: 
#   models: ->(model) { check } | Array of Models
#   if: ->(record) { check } | unless: ->(record) { check }
#   on: [:reads, :writes]
#   actions: [:create, :update, :delete] | [:index, :search]

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

# Model Setup:

# enable_journal default_context
