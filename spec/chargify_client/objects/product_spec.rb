require "spec_helper"

RSpec.describe ChargifyClient::Objects::Product do
  subject { described_class.new(client: client, chargify_hash: chargify_hash)}
  let(:client) { instance_double(ChargifyClient) }
  let(:chargify_hash) {
    {
      id: 777,
      name: "Productive Product",
      handle: "productive_product",
      require_credit_card: true,
      product_family: {
        id: 99,
        name: "Productive Family",
        handle: "productive_family"
      }
    }
  }

  it "makes attributes of the chargify_hash available as attributes of the object" do
    expect(subject.id).to eq 777
    expect(subject.name).to eq "Productive Product"
    expect(subject.handle).to eq "productive_product"
    expect(subject.require_credit_card).to eq true
  end

  it "sets a product_family object with product_family attributes" do
    product_family = subject.product_family
    expect(product_family).to be_a(ChargifyClient::Objects::ProductFamily)
    expect(product_family.id).to eq 99
    expect(product_family.name).to eq "Productive Family"
    expect(product_family.handle ).to eq "productive_family"
  end
end
