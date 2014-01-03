EXPORT_URL = %r!https://us6.api.mailchimp.com/export/1.0/(?:[a-z0-9]+)!
MAILCHIMP_URL = %r!https://us6.api.mailchimp.com/\d.\d/(?:[a-z0-9/]+)!
ERROR_URL = %r!https://us6.api.mailchimp.com/\d.\d/error!

module FeralchimpHelpers
  def get_stub_response(name)
    name = File.expand_path("../../fixtures/#{name}.json", __FILE__)
    IO.read(name)
  end

  def to_constant(name)
    Object.const_get(name.to_s.chars.map do |c|
      c.capitalize
    end.join)
  end

  def stub_response(name, sub_name = nil)
    WebMock.stub_request(:any, to_constant(name)).to_return({
      :body => get_stub_response(name)
    })
  end
end

RSpec.configure do |c|
  c.include FeralchimpHelpers
end
