EXPORT_URL = %r!https://us6.api.mailchimp.com/export/1.0/(?:[a-z0-9]+)!
ERROR_URL = {
  1.3 => %r!https://us6.api.mailchimp.com/\d.\d/\?method=error!,
  2.0 => %r!https://us6.api.mailchimp.com/\d.\d/error!
}
MAILCHIMP_URL = {
  1.3 => %r!https://us6.api.mailchimp.com/\d.\d/\?method=(?:[a-z0-9]+)!,
  2.0 => %r!https://us6.api.mailchimp.com/\d.\d/(?:[a-z0-9/]+)!
}

module RSpec
  module Helpers
    module FeralchimpHelpers
      def get_stub_response(name)
        IO.read(File.expand_path("../../fixtures/#{name}.json", __FILE__))
      end

      def to_constant(name)
        Object.const_get(name.to_s.chars.map { |c| c.capitalize }.join)
      end

      def stub_response(name, sub_name = nil)
        url = to_constant(name) and (url = url[sub_name] if sub_name)
        WebMock.stub_request(:any, url).to_return(:body => get_stub_response(name))
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Helpers::FeralchimpHelpers
end
