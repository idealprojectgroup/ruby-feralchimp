source "https://rubygems.org"
gemspec

group :development do
  unless ENV["CI"]
    gem "pry"
  end

  gem "rake"
end

group :test do
  platforms :rbx do
    gem "rubysl"
  end
end
