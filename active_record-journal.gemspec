
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/journal/version"

Gem::Specification.new do |spec|
  spec.name          = 'active_record-journal'
  spec.version       = ActiveRecord::Journal::VERSION
  spec.authors       = ['mkiroshdz']
  spec.email         = ['mkirosh@hey.com']

  spec.summary       = 'A gem to track changes on active record models'
  spec.description   = 'A gem to track changes on active record models'
  spec.homepage      = 'https://github.com/mkiroshdz/active_record-journal'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = 'https://rubygems.org/'
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = 'https://github.com/mkiroshdz/active_record-journal'
    spec.metadata["changelog_uri"] = 'https://github.com/mkiroshdz/active_record-journal/blob/CHANGELOG.md'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 6.0.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
