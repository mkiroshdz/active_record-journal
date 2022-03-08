# frozen_string_literal: true

module AppFilesHelper
  def app_root
    @app_root ||= ENV['RAILS_RELATIVE_URL_ROOT']
  end
end
