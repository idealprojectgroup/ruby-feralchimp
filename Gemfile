source "https://rubygems.org"
gemspec

group :development do
  gem 'envygeeks-coveralls', :github => 'envygeeks/envygeeks-coveralls'
  gem 'luna-rspec-formatters'
  gem 'pry'

  # --------------------------------------------------------------------------
  # Dependencies for people using Bundler.
  # --------------------------------------------------------------------------

  gem 'rake'

  unless ENV['CI']
    gem 'guard-rspec'
    gem 'listen', :github => 'envygeeks/listen'
  end
end
