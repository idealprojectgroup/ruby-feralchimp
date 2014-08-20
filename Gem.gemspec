$:.unshift(File.expand_path("../lib", __FILE__))
require "feralchimp/version"

Gem::Specification.new do |spec|
  spec.description = "A simple API wrapper for Mailchimp that uses Faraday."
  spec.files = %W(Rakefile Gemfile Readme.md License) + Dir["lib/**/*"]
  spec.homepage = "http://github.com/envygeeks/feralchimp/"
  spec.summary = "A simple API wrapper for Mailchimp."
  spec.email = ["jordon@envygeeks.com"]
  spec.version = Feralchimp::VERSION
  spec.name = "feralchimp"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.require_paths = ["lib"]
  spec.authors = ["Jordon Bedwell"]

  spec.add_runtime_dependency("json", "~> 1.8")
  spec.add_runtime_dependency("faraday", "~> 0.9.0")
  spec.add_development_dependency("luna-rspec-formatters", "~> 1.2.2")
  spec.add_development_dependency("envygeeks-coveralls", "~> 0.2")
  spec.add_development_dependency("webmock", "~> 1.18")
  spec.add_development_dependency("rspec", "~> 3.0")
end
