require "spec_helper"
require "faraday"
require "chargify_client/response_error"

RSpec.describe ChargifyClient::ResponseError do
  let(:response) { instance_double(Faraday::Response,
    env: env, success?: false, reason_phrase: "I'm a teapot", status: 422
  )}
  let(:env) { instance_double(Faraday::Env, body: "") }

  describe ".disallow" do
    it "raises a 405 error" do
      expect { described_class.disallow }.
        to raise_error(described_class, "405: Method Not Allowed")
    end
  end

  describe ".from_response" do
    subject { described_class.from_response(response) }

    it "builds message from status and reason_phrase" do
      expect(subject.message).to eq "422: I'm a teapot"
    end

    it "includes the status code" do
      expect(subject.status).to eq 422
    end

    it "includes the reason_phrase as error_reason" do
      expect(subject.error_reason).to eq "I'm a teapot"
    end

    it "includes the reason_phrase as error_details" do
      expect(subject.error_details).to eq ["I'm a teapot"]
    end

    context "when response includes an env body" do
      let(:env) { instance_double(Faraday::Env,
        body: "{\"errors\": [\"first error\", \"second error\"]}")
      }

      it "builds message from status and env body" do
        expect(subject.message).to eq "422: first error; second error"
      end

      it "includes the status code" do
        expect(subject.status).to eq 422
      end

      it "includes the reason_phrase as error_reason" do
        expect(subject.error_reason).to eq "I'm a teapot"
      end

      it "includes the env body as error_details" do
        expect(subject.error_details).to eq ["first error", "second error"]
      end

    end

    context "when response was successful" do
      let(:response) { instance_double(
        Faraday::Response, success?: true, status: 203
      )}

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when response is unsuccessful but error_details can not be parsed" do
      let(:response) { instance_double(Faraday::Response,
        env: env, success?: false, reason_phrase: "I'm a teapot", status: 422
      )}
      let(:env) { instance_double(Faraday::Env, body: "this will not parse as json") }

      it "builds message with status and 'unparsable error'" do
        expect(subject.message).to eq "422: unparsable error"
      end

      it "includes the status code" do
        expect(subject.status).to eq 422
      end

      it "includes the reason_phrase as error_reason" do
        expect(subject.error_reason).to eq "I'm a teapot"
      end

      it "includes the env body as error_details" do
        expect(subject.error_details).to eq ["unparsable error"]
      end
    end
  end
end
