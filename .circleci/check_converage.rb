#!/usr/bin/env ruby

require 'simplecov'

SimpleCov.root((ENV['RAILS_RELATIVE_URL_ROOT']).to_s)
result = SimpleCov::LastRun.read[:result].values.min
threshold = ENV['SPEC_COVERAGE_THRESHOLD']&.to_i
result >= threshold ? exit(true) : exit(false) 
