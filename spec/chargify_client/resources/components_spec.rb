require "spec_helper"

RSpec.describe ChargifyClient::Resources::Components do
  let(:client) { ChargifyClient.new(
    api_key: "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", subdomain: "goldstar-acme"
  )}

  describe "find_by_reference", vcr: { cassette_name: "components" } do
    subject { client.components.find_by_reference("sample-metered-impressions") }

    it "returns a component" do
      expect(subject).to be_a(ChargifyClient::Objects::Component)
    end
  end

  context "disallowed calls" do
    shared_examples_for :does_not_allow_call do
      it "raises a 405 error" do
        expect { subject }.to raise_error(
          ChargifyClient::ResponseError, "405: Method Not Allowed"
        )
      end
    end

    describe "find_all" do
      subject { client.components.find_all }
      it_behaves_like :does_not_allow_call
    end

    describe "find_by_id" do
      subject { client.components.find_by_id("anything") }
      it_behaves_like :does_not_allow_call
    end

    describe "create" do
      subject { client.components.create(any: "thing") }
      it_behaves_like :does_not_allow_call
    end
  end

end
