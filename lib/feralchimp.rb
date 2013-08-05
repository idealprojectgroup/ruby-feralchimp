require "feralchimp/version"
require "faraday"
require "json"
require "uri"
require "cgi"

# Allow for export(1).list flow.
class FeralchimpErrorHash < Hash
  def initialize(hash = nil)
    self.replace(hash) if Hash === hash
    super
  end

  def method_missing(method, *args)
    return self
  end
end

class Object
  def to_mailchimp_method(api_version)
    api_version.to_f >= 2.0 ? __to_mailchimp_2_method : __to_mailchimp_1_method
  end

  def blank?
    respond_to?(:empty?) ? (empty?) : (!self)
  end

  private
  def __to_mailchimp_2_method
   out = self.to_s.split("_")
   "#{out[0]}#{("/" + out[1..-1].join("-")) if out.count > 1}"
  end

  private
  def __to_mailchimp_1_method
    self.to_s.gsub(/_(.)/) do
      $1.capitalize
    end
  end
end

class Feralchimp
  @export_version = '1.0'
  @api_version = '2.0'
  @exportar = false
  @raise = false
  @timeout = 5
  @key = ENV["MAILCHIMP_API_KEY"]

  [:KeyError, :MailchimpError].each do |o|
    const_set o, Class.new(StandardError)
  end

  def initialize(key = nil)
    @key = key || self.class.key
  end

  def method_missing(method, *args)
    if method == :export
      raise ArgumentError, "#{args.count} for 0" if args.count > 0
      self.class.exportar = true
      return self
    else
      send_to_mailchimp(method, *args)
    end
  rescue => error
    if self.class.raise
      raise error
    else
      FeralchimpErrorHash.new({ "object" => error, "code" => 9001, "error" => error.message })
    end
  end

  private
  def send_to_mailchimp(method, bananas = {}, export = self.class.exportar)
    key = parse_key(bananas.delete(:apikey) || @key)
    self.class.exportar = false
    method = method.to_mailchimp_method(self.class.api_version)
    send_to_mailchimp_http(key.last, method, bananas.merge(:apikey => key.first), export)
  end

  private
  def send_to_mailchimp_http(zone, method, bananas, export)
    bananas = bananas.to_json if self.class.api_version.to_f >= 2.0
    raise_or_return mailchimp_http(zone, export).post(api_path(export) % method, bananas).body
  end

  private
  def mailchimp_http(zone, export)
    Faraday.new(:url => api_url(zone)) do |http|
      http.options[:open_timeout] = self.class.timeout
      http.options[:timeout] = self.class.timeout
      mailchimp_extra_headers(http)
      http.response(export ? :mailchimp_export : :mailchimp)
      http.adapter(Faraday.default_adapter)
    end
  end

  private
  def mailchimp_extra_headers(obj)
    self.class.api_version.to_f >= 2.0 ?
      obj.headers[:content_type] = "application/json" : obj.request(:url_encoded)
  end

  private
  def parse_key(key)
    unless key =~ %r!\w+-{1}[a-z]{2}\d{1}!
      raise KeyError, "Invalid key#{": #{key}" unless key.blank?}."
    end

    key.split("-")
  end

  private
  def api_path(export = false)
    if export
      "/export/#{self.class.export_version}/%s/"
    else
      self.class.api_version.to_f >= 2.0 ?
        "/#{self.class.api_version}/%s.json" : "/#{self.class.api_version}/?method=%s"
    end
  end

  private
  def api_url(zone)
    URI.parse("https://#{zone}.api.mailchimp.com")
  end

  private
  def raise_or_return(rtn)
    if self.class.raise && (rtn.is_a?(Hash) && rtn.has_key?("error"))
      raise MailchimpError, rtn["error"]
    end

  rtn
  end

  class << self
    attr_accessor :exportar, :raise, :timeout, :key, :api_version, :export_version
    alias :apikey= :key=; alias :apikey :key
    alias :api_key= :key=; alias :api_key :key

    def method_missing(method, *args)
      new.send(*args.unshift(method))
    end
  end

  module Response
    class JSON < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete { |env|
          env[:raw_body] = env[:body]
          env[:body] =
            ::JSON.parse("[" + env[:raw_body].to_s + "]").first
        }
      end
    end

    class JSONExport < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete { |env|
          env[:raw_body] = env[:body]

          body = env[:body].each_line.to_a
          keys = ::JSON.parse(body.shift)
          env[:body] = body.inject([]) { |a, k|
            a.push(Hash[keys.zip(::JSON.parse(k))])
          }
        }
      end
    end
  end
end

{ :mailchimp => :JSON, :mailchimp_export => :JSONExport }.each do |m, o|
  o = Feralchimp::Response.const_get(o)
  Faraday.register_middleware(:response, m => proc { o })
end
