require "spec_helper"

RSpec.describe ChargifyClient::Resources::ProductFamilies do
  let(:client) { ChargifyClient.new(
    api_key: "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", subdomain: "goldstar-acme"
  )}

  describe "find_by_reference" do
    it "raises an error" do
      expect { client.product_families.find_by_reference("anything") }.
        to raise_error(ChargifyClient::ResponseError, "405: Method Not Allowed")
    end
  end

  describe "find_all", vcr: { cassette_name: "product_families" } do
    subject { client.product_families.find_all }

    it "returns a collection of product_families" do
      expect(subject.length).to eq 2
      subject.each {|family|
        expect(family).to be_a(ChargifyClient::Objects::ProductFamily)
      }
    end
  end

  describe "find_by_id", vcr: { cassette_name: "product_families" } do
    subject { client.product_families.find_by_id(1511046) }

    it "returns a product family" do
      expect(subject).to be_a(ChargifyClient::Objects::ProductFamily)
    end
  end

  describe "create", vcr: { cassette_name: "product_families" } do
    subject { client.product_families.create(payload) }
    let(:payload) {
      {
        name: "My New Family",
        description: "A big happy . . .",
        handle: "my_new_family"
      }
    }

    it "returns a product family" do
      expect(subject).to be_a(ChargifyClient::Objects::ProductFamily)
    end
  end

end
