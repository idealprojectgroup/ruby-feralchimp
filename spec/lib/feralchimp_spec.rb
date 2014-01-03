require "rspec/helper"

# ---------------------------------------------------------------------
# Shared examples that describe Feralchimp in 1.0 and 2.0 mode.
# ---------------------------------------------------------------------

describe Feralchimp do
  describe "#to_mailchimp_method" do
    subject do
      described_class.new(:api_key => "foo-us6")
    end

    specify "foo_bar => foo/bar" do
      result = subject.send(:mailchimp_method, "foo_bar")
      expect(result).to eq "foo/bar"
    end

    specify "foo => foo" do
      expect(subject.send(:mailchimp_method, "foo")).to eq "foo"
    end

    specify "foo_bar_baz => foo/bar-baz" do
      result = subject.send(:mailchimp_method, "foo_bar_baz")
      expect(result).to eq "foo/bar-baz"
    end
  end

  before :each do
    Feralchimp.class_eval do
      @api_key, @exportar, @timeout = nil, nil, nil
    end
  end

  it "allows api keys on initialize" do
    stub_response(:mailchimp_url)
    expect(Feralchimp.new(:api_key => "foo-us6").list).to eq({
      "total" => 1
    })
  end

  it "allows constant API keys" do
    stub_response(:mailchimp_url)
    Feralchimp.api_key = "foo-us6"
    expect(Feralchimp.lists).to eq({
      "total" => 1
    })
  end

  context ".export" do
    it "parses the output to an array of hashes" do
      stub_response(:export_url)
      expect(Feralchimp.new(:api_key => "foo-us6").export.lists).to eq([
        {
          "header1" => "return1",
          "header2" => "return2"
        },

        {
          "header1" => "return1",
          "header2" => "return2"
        }
      ])
    end

    it "doesn't allow arguments" do
      Feralchimp.api_key = "foo-us6"
      expect_error(ArgumentError) do
        Feralchimp.export(true)
      end
    end
  end

  it "outputs a hash" do
    stub_response(:mailchimp_url)
    expect(Feralchimp.new(:api_key => "foo-us6").lists).to eq({
      "total" => 1
    })
  end

  it "raises the error that Mailchimp gives" do
    stub_response(:error_url)
    expect_error(Feralchimp::MailchimpError) do
      Feralchimp.new(:api_key => "foo-us6").error
    end
  end

  it "skips if the method is to_ary" do
    expect_error(NoMethodError) do
      Feralchimp.to_ary
    end
  end

  describe "#parse_key" do
    it "doesn't allow invalid keys" do
      expect_error(Feralchimp::KeyError) do
        Feralchimp.new(:api_key => "foo").foo
      end
    end

    it "doesn't allow nil values" do
      expect_error(Feralchimp::KeyError) do
        Feralchimp.new.foo
      end
    end
  end
end
