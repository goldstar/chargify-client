require "spec_helper"

RSpec.describe ChargifyClient::Objects::Component do
  subject { described_class.new(client: client, chargify_hash: chargify_hash)}
  let(:post_response) { {usage: {id: 171}} }
  let(:client) { instance_double(ChargifyClient, post: post_response) }
  let(:component_kind) { "metered_component" }
  let(:chargify_hash) {
    {
      id: 111,
      name: "My Cool Component",
      handle: "my_cool_component",
      price_per_unit_in_cents: 500,
      kind: component_kind,
      product_family_id: 99,
      prices: [
        {
          id: 222,
          component_id: 111,
          starting_quantity: 7
        },{
          id: 333,
          component_id: 111,
          starting_quantity: 14
        }
      ]
    }
  }

  describe "add_usage" do
    let(:payload) {
      {
        subscription_id: 1234,
        quantity: 8
      }
    }

    it "calls client with payload minus subscription_id wrapped as usage" do
      subject.add_usage(payload)
      expect(client).to have_received(:post).with(
        path: "/subscriptions/1234/components/111/usages.json",
        body: {usage: {quantity: 8}}
      )
    end

    it "returns a usage object" do
      usage = subject.add_usage(payload)
      expect(usage).to be_a(ChargifyClient::Objects::Usage)
      expect(usage.id).to eq 171
    end

    context "when called without subscription_id" do
      it "raises a 400" do
        expect { subject.add_usage(quantity: 4, memo: "used it") }.
          to raise_error(ChargifyClient::ResponseError, "400: Must include subscription_id")
      end
    end

    context "when called without quantity" do
      it "raises a 400" do
        expect { subject.add_usage(subscription_id: 4, memo: "used it") }.
          to raise_error(ChargifyClient::ResponseError, "400: Must include quantity")
      end
    end

    context "when the component is not a metered_component" do
      let(:component_kind) { "quantity_based_component" }

      it "raises a 406 error" do
        expect { subject.add_usage(payload) }.to raise_error(
          ChargifyClient::ResponseError,
          "406: Usage can only be applied to a metered component"
        )
      end
    end
  end

  describe "product_family" do
    let(:product_family) {
      instance_double(ChargifyClient::Objects::ProductFamily)
    }
    let(:product_families) {
      instance_double(ChargifyClient::Resources::ProductFamilies)
    }

    before "mock product_families" do
      allow(client).to receive(:product_families).and_return(product_families)
      allow(product_families).to receive(:find_by_id).and_return(product_family)
    end

    it "returns product_family_id from attributes" do
      expect(subject.product_family_id).to eq 99
      expect(product_families).not_to have_received(:find_by_id)
    end

    it "looks up the product_family using the product_family_id attribute" do
      expect(subject.product_family).to eq product_family
      expect(product_families).to have_received(:find_by_id).with(99)
    end
  end

  it "makes attributes of the chargify_hash available as attributes of the object" do
    expect(subject).to be_a ChargifyClient::Objects::Component
    expect(subject.id).to eq 111
    expect(subject.name).to eq "My Cool Component"
    expect(subject.handle).to eq "my_cool_component"
    expect(subject.price_per_unit_in_cents).to eq 500
  end

  it "sets prices from prices attribute array" do
    prices = subject.prices
    expect(prices.length).to eq 2
    prices.each {|price| expect(price).to be_a(ChargifyClient::Objects::Price) }
    expect(prices[0].id).to be 222
    expect(prices[0].starting_quantity).to eq 7
    expect(prices[1].id).to be 333
    expect(prices[1].starting_quantity).to eq 14
  end
end
