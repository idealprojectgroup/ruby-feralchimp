MAILCHIMP_URL = %r!https://us6.api.mailchimp.com/1.3/\?method=(?:[a-z0-9]+)!
EXPORT_URL = %r!https://us6.api.mailchimp.com/export/1.0/(?:[a-z0-9]+)!
ERROR_URL = "https://us6.api.mailchimp.com/1.3/?method=error"

module RSpec
  module Helpers
    module FeralchimpHelpers
      def get_stub_response(name)
        IO.read(File.expand_path("../../fixtures/#{name}.json", __FILE__))
      end

      def to_constant(name)
        Object.const_get(name.to_s.chars.map { |c| c.capitalize }.join)
      end

      def stub_response(name)
        WebMock.stub_request(:any, to_constant(name)).to_return(body: get_stub_response(name))
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Helpers::FeralchimpHelpers
end
