require "spec_helper"
# require "chargify_client/resources/products"

RSpec.describe ChargifyClient::Resources::Products do
  let(:client) { ChargifyClient.new(
    api_key: "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", subdomain: "goldstar-acme"
  )}

  describe ".find_all", vcr: { cassette_name: "products" } do
    subject { client.products.find_all }

    it "returns a collection of products" do
      expect(subject.length).to eq 2
      subject.each {|product|
        expect(product).to be_a(ChargifyClient::Objects::Product)
      }
    end
  end
end
