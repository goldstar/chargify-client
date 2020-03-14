require "spec_helper"

RSpec.describe ChargifyClient do
  let(:subdomain) { "thesubdomain" }
  let(:api_key) { "thekey" }
  let(:faraday_response) {
    instance_double(Faraday::Response, body: "{\"key\": \"value\"}", success?: true)
  }
  let(:faraday_env) { instance_double(Faraday::Env, body: "") }

  let(:auth_header) do
    { authorization: "Basic #{Base64.strict_encode64("#{api_key}:X")}" }
  end

  describe "get" do
    let(:client) { described_class.new(api_key: api_key, subdomain: subdomain) }
    let(:expected_headers) { auth_header }
    before "mock calls to Faraday" do
      allow(Faraday).to receive(:get).and_return(faraday_response)
    end

    it "hits chargify site at the expected path and with auth headers" do
      client.get(path: "the_path")
      expect(Faraday).to have_received(:get).
        with("https://#{subdomain}.chargify.com/the_path", {}, expected_headers)
    end

    it "can include params and additional headers" do
      client.get(path: "the_path", params: {foo: "bar"}, headers: {blee: "blah"})
      expect(Faraday).to have_received(:get).with(
        "https://#{subdomain}.chargify.com/the_path",
        {foo: "bar"},
        {blee: "blah"}.merge(expected_headers)
      )
    end

    it "returns hash of returned json" do
      expect(client.get(path: "path")[:key]).to eq "value"
    end

    context "when response is not successful" do
      let(:faraday_response) { instance_double(Faraday::Response,
        env: faraday_env, success?: false, status: 499, reason_phrase: "Big Error"
      )}

      it "raises an error" do
        expect { client.get(path: "impending_doom") }.
          to raise_error(ChargifyClient::ResponseError)
      end
    end
  end

  describe "post" do
    let(:client) { described_class.new(api_key: api_key, subdomain: subdomain) }
    let(:expected_headers) { auth_header.merge("Content-Type" => "application/json") }
    before "mock calls to Faraday" do
      allow(Faraday).to receive(:post).and_return(faraday_response)
    end

    context "when no body is included" do
      it "hits chargify site at the expected path and with an empty body" do
        client.post(path: "the_path")
        expect(Faraday).to have_received(:post).
          with("https://#{subdomain}.chargify.com/the_path", "", expected_headers )
      end
    end

    context "when a body and additional headers are passed" do
      it "hits chargify site with body formatted as json and other headers included" do
        client.post(path: "the_path", body: {foo: "bar"}, headers: {blee: "blah"})
        expect(Faraday).to have_received(:post).with(
          "https://#{subdomain}.chargify.com/the_path",
          {foo: "bar"}.to_json,
          {blee: "blah"}.merge(expected_headers)
        )
      end
    end

    it "returns hash of returned json" do
      expect(client.post(path: "path")[:key]).to eq "value"
    end

    context "when resopnse has no body" do
      let(:faraday_response) {
        instance_double(Faraday::Response, body: "", success?: true)
      }

      it "does not error" do
        expect { client.post(path: "path") }.not_to raise_error
      end

      it "returns nil" do
        expect(client.post(path: "path")).to be_nil
      end
    end

    context "when response is not successful" do
      let(:faraday_response) { instance_double(Faraday::Response,
        env: faraday_env, success?: false, status: 499, reason_phrase: "Big Error"
      )}

      it "raises an error" do
        expect { client.post(path: "impending_doom") }.
          to raise_error(ChargifyClient::ResponseError)
      end
    end
  end

  describe "constructor" do
    it "requires api_key and subdomain" do
      expect {described_class.new(api_key: "key", subdomain: "sub")}.
        not_to raise_error
    end

    it "raises an error if api_key is not provided" do
      expect {described_class.new(subdomain: "sub")}.to raise_error(ArgumentError)
    end

    it "raises an error if subdomain is not provided" do
      expect {described_class.new(api_key: "key")}.to raise_error(ArgumentError)
    end

    context "when a class exists in the resources directory" do
      subject { described_class.new(api_key: "key", subdomain: "sub") }

      let(:current_path) { File.expand_path(File.dirname(__FILE__)) }
      let(:resource_file_path) {
        File.join(current_path, "..", "lib", "chargify_client", "resources", "foo_bars.rb")
      }

      before "write a new resources class" do
        File.open(resource_file_path, "w") do |file|
          file.write foo_bar_file_contents
        end
      end

      after "remove the resources class" do
        File.delete(resource_file_path) if File.exist?(resource_file_path)
      end

      it "creates a method which returns an instance of the class" do
        expect(subject.foo_bars).not_to be_nil
        expect(subject.foo_bars.get_message).to eq "the message"
      end

      it "does not include 'base' as a method" do
        expect { subject.base }.to raise_error(NoMethodError)
      end
    end
  end

  def foo_bar_file_contents
    <<~CONTENTS
class ChargifyClient
  module Resources
    class FooBars < ChargifyClient::Resources::Base
      def get_message
        "the message"
      end
    end
  end
end
    CONTENTS
  end
end
