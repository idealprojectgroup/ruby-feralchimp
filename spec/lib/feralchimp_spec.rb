require "rspec/helper"

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

  context "when MAILCHIMP_API_KEY is set in the environment" do
    before do
      ENV['MAILCHIMP_API_KEY'] = 'foo-us6'
    end

    after do
      ENV['MAILCHIMP_API_KEY'] = nil
    end

    it "defaults to the key sent in the environment" do
      stub_response(:mailchimp_url)
      expect(Feralchimp.lists).to eq({
        "total" => 1
      })
      expect(Feralchimp.new.lists).to eq({
        "total" => 1
      })
    end
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
      expect { Feralchimp.export(true) }.to raise_error ArgumentError
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
    expect { Feralchimp.new(:api_key => "foo-us6").error
      }.to raise_error Feralchimp::MailchimpError
  end

  it "skips if the method is to_ary" do
    expect { Feralchimp.to_ary }.to raise_error NoMethodError
  end

  describe "#parse_key" do
    it "doesn't allow invalid keys" do
      expect { Feralchimp.new(:api_key => "foo")
        }.to raise_error Feralchimp::KeyError
    end

    it "doesn't allow nil values" do
      expect { Feralchimp.new.foo }.to raise_error Feralchimp::KeyError
    end
  end
end
