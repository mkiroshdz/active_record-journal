# frozen_string_literal: true

require 'simplecov'

SimpleCov.root((ENV['RAILS_RELATIVE_URL_ROOT']).to_s)
SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch
  add_filter '/spec/'
  formatter SimpleCov::Formatter::SimpleFormatter
end
