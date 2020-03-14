require "spec_helper"

RSpec.describe ChargifyClient::Resources::Customers do
  let(:client) { ChargifyClient.new(
    api_key: "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", subdomain: "goldstar-acme"
  )}

  describe ".find_all", vcr: { cassette_name: "customers" } do
    subject { client.customers.find_all }

    it "returns a collection of customers" do
      expect(subject.length).to eq 3
      subject.each {|customer|
        expect(customer).to be_a(ChargifyClient::Objects::Customer)
      }
    end
  end

  describe ".find_by_id", vcr: { cassette_name: "customers" } do
    subject { client.customers.find_by_id(32708421) }

    it "returns a customer" do
      expect(subject).to be_a(ChargifyClient::Objects::Customer)
    end
  end

  describe ".create", vcr: { cassette_name: "customers" } do
    subject { client.customers.create(payload) }
    let(:payload) {
      {
        first_name: "Fred",
        last_name: "Flintstone",
        email: "fred@example.com",
        reference: "user_fred"
      }
    }

    it "returns a customer" do
      expect(subject).to be_a(ChargifyClient::Objects::Customer)
    end
  end

end
