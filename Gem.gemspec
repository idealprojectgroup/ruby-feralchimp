$:.unshift(File.expand_path("../lib", __FILE__))
require "feralchimp/version"

Gem::Specification.new do |spec|
  spec.description = "A simple API wrapper for Mailchimp that uses Faraday."
  spec.files = %W(Rakefile Gemfile Readme.md License) + Dir["lib/**/*"]
  spec.homepage = "http://github.com/envygeeks/feralchimp/"
  spec.summary = "A simple API wrapper for Mailchimp."
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Feralchimp::VERSION
  spec.name = "feralchimp"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.require_paths = ["lib"]
  spec.authors = ["Jordon Bedwell"]

  spec.add_runtime_dependency("json", "~> 1.8")
  spec.add_runtime_dependency("faraday", "~> 0.8")
  spec.add_development_dependency("rspec", "~> 2.14")
  spec.add_development_dependency("webmock", "~> 1.13")
  spec.add_development_dependency("rspec-expect_error", "~> 0.0")
  spec.add_development_dependency("envygeeks-coveralls", "~> 0.1")
  spec.add_development_dependency("luna-rspec-formatters", "~> 0.4")
end
