require "support/simplecov"
require "luna/rspec/formatters/checks"
require "rspec/expect_error"
require "webmock/rspec"
require "feralchimp"
WebMock.disable_net_connect!

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end

module RSpecFixes
  def to_ary
    raise NoMethodError
  end
end

[FeralchimpErrorHash, Feralchimp].each do |c|
  c.send(:include, RSpecFixes)
end
