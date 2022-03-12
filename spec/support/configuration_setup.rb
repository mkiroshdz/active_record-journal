# frozen_string_literal: true

module ConfigurationSetup
  def self.clear!
    ActiveRecord::Journal.instance_variable_set('@configuration', nil)
  end

  def self.init(init_params)
    ActiveRecord::Journal.configuration.tap do |c|
      c.instance_variable_set('@entries_class', nil)
      c.instance_variable_set('@tags_class', nil)
      c.entries_class = init_params[:entries_class] || JournalRecord
      c.tags_class = init_params[:tags_class] || JournalTag
      c.autorecording_enabled = init_params[:autorecording_enabled]
    end
  end
end
