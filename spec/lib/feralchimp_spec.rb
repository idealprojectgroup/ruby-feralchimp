require "rspec/helper"

describe Object do
  describe "#to_mailchimp_method" do
    context "v1.3" do
      it "returns testMethod if given test_method" do
        expect("test_method".to_mailchimp_method(1.3)).to eq "testMethod"
      end

      it "returns testMethod if given testMethod" do
        expect("testMethod".to_mailchimp_method(1.3)).to eq "testMethod"
      end
    end

    context "v2.0" do
      it "returns test/method and test/method-name if given those" do
        expect("test_method".to_mailchimp_method(2.0)).to eq "test/method"
        expect("test_method_name".to_mailchimp_method(2.0)).to eq "test/method-name"
      end

      it "returns just test if given test" do
        expect("test".to_mailchimp_method(2.0)).to eq "test"
      end
    end
  end

  describe "#blank?" do
    it "works on a hash, string and array" do
      expect([{}.blank?, [].blank?, "".blank?]).to eq [true, true, true]
    end
  end
end

describe FeralchimpErrorHash do
  it "returns the hash if given a hash" do
    expect(FeralchimpErrorHash.new(:test => 1)).to eq test: 1
  end

  it "returns a hash if given nothing" do
    expect(FeralchimpErrorHash.new).to be_kind_of Hash
  end

  it "proxies and always return a hash on method_missing" do
    expect(Feralchimp.new.hello.world).to be_kind_of Hash
  end
end

# ----------------------------------------------------------------------------
# Shared examples that describe Feralchimp in 1.0 and 2.0 mode.
# ----------------------------------------------------------------------------

shared_examples :Feralchimp do
  before :each do
    Feralchimp.api_version = @api_version
    ENV.delete("MAILCHIMP_API_KEY")
    Feralchimp.class_eval {
      @timeout = nil
      @raise = nil
      @key = nil
      @exportar = nil
    }
  end

  it "aliases key over to api_key" do
    expect(Feralchimp).to respond_to :api_key
    expect(Feralchimp).to respond_to :api_key=
  end

  it "should aliases key over to apikey" do
    expect(Feralchimp).to respond_to :apikey
    expect(Feralchimp).to respond_to :apikey=
  end

  it "accepts a timeout" do
    expect(Feralchimp).to respond_to :timeout
    expect(Feralchimp).to respond_to :timeout=
  end

  it "allows users to disable raising" do
    stub_response(:mailchimp_url, @api_version)
    Feralchimp.raise = false
    expect(Feralchimp.error["error"]).to eq "Invalid key."
  end

  it "allows users to enable raising" do
    stub_response(:mailchimp_url, @api_version)
    Feralchimp.raise = true
    expect_error(Feralchimp::KeyError) { Feralchimp.hello }
  end

  it "allows users to set a constant key" do
    stub_response(:mailchimp_url, @api_version)
    Feralchimp.key = "hello-us6"
    expect(Feralchimp.lists).to eq "total" => 1
  end

  it "allows users to set an instance key" do
    stub_response(:mailchimp_url, @api_version)
    expect(Feralchimp.new("hello-us6").lists).to eq "total" => 1
  end

  it "parses MailChimp export API into an array of Hash-es" do
    stub_response(:export_url)
    expect(Feralchimp.new("hello-us6").export.lists).to eq [
      {
        "header1" => "return1",
        "header2" => "return2"
      },
      {
        "header1" => "return1",
        "header2" => "return2"
      }
    ]
  end

  it "raises an ArgumentError if arguments are given" do
    Feralchimp.raise = true
    expect_error(ArgumentError) { Feralchimp.export(true) }
  end

  it "outputs a hash" do
    stub_response(:mailchimp_url, @api_version)
    expect(Feralchimp.new("hello-us6").lists).to eq "total" => 1
  end

  it "raises errors that Mailchimp gives" do
    stub_response(:error_url, @api_version)
    Feralchimp.raise = true
    expect_error(Feralchimp::MailchimpError) { Feralchimp.new("hello-us6").error }
  end
end

# ----------------------------------------------------------------------------
# The actual testing.
# ----------------------------------------------------------------------------

describe Feralchimp do
  context "v1.3" do
    before do
      @api_version = 1.3
    end

    it_behaves_like :Feralchimp
  end

  context "v2.0" do
    before do
      @api_version = 2.0
    end

    it_behaves_like :Feralchimp
  end
end
