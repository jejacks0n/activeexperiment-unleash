# frozen_string_literal: true

require_relative "lib/active_experiment/unleash_adapter/version"
version = ActiveExperiment::UnleashAdapter.version

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "activeexperiment-unleash"
  s.version     = version
  s.summary     = "Unleash adapter for Active Experiment."
  s.description = "Use Unleash as a rollout and reporting service for Active Experiment."

  s.required_ruby_version = ">= 2.7.0"

  s.license = "MIT"

  s.author   = "Jeremy Jackson"
  s.email    = "jejacks0n@gmail.com"
  s.homepage = "https://github.com/jejacks0n/activeexperiment-unleash"

  s.files        = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*"]
  s.require_path = "lib"

  s.metadata = {
    "homepage_uri"      => s.homepage,
    "source_code_uri"   => s.homepage,
    "bug_tracker_uri"   => s.homepage + "/issues",
    "changelog_uri"     => s.homepage + "/CHANGELOG.md",
    "documentation_uri" => s.homepage + "/README.md",
    "rubygems_mfa_required" => "true",
  }

  s.add_dependency "activeexperiment", ">= 0.1.1.alpha"
  s.add_dependency "unleash", ">= 4.4.1"
end
