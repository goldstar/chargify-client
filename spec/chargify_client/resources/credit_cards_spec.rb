require "spec_helper"

RSpec.describe ChargifyClient::Resources::CreditCards do
  let(:client) { ChargifyClient.new(
    api_key: "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", subdomain: "goldstar-acme"
  )}

  describe "find_by_id", vcr: { cassette_name: "credit_cards" } do
    subject { client.credit_cards.find_by_id(22658910) }

    it "returns a credit_card" do
      expect(subject).to be_a(ChargifyClient::Objects::CreditCard)
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
      subject { client.credit_cards.find_all }
      it_behaves_like :does_not_allow_call
    end

    describe "find_by_reference" do
      subject { client.credit_cards.find_by_reference("anything") }
      it_behaves_like :does_not_allow_call
    end

    describe "create" do
      subject { client.credit_cards.create(any: "thing") }
      it_behaves_like :does_not_allow_call
    end
  end

end
