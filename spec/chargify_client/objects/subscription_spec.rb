require "spec_helper"

RSpec.describe ChargifyClient::Objects::Subscription do
  subject { described_class.new(client: client, chargify_hash: chargify_hash)}
  let(:client) { instance_double(ChargifyClient, post: nil) }
  let(:chargify_hash) {
    {
      id: 12345,
      balance_in_cents: 7654,
      customer: {
        first_name: "Wilma",
        last_name: "Flintstone"
      },
      product: {
        id: 987,
        name: "Thingamajig",
        handle: "thingy",
        product_family: {
          id: 8,
          name: "All In"
        }
      },
      credit_card: {
        id: 555,
        masked_card_number: "xxx"
      }
    }
  }

  describe "apply_service_credit" do
    let(:payload) {
      { amount: "20.00", memo: "Taken from ticket sales" }
    }

    it "calls client with payload wrapped as service_credit" do
      subject.apply_service_credit(payload)
      expect(client).to have_received(:post).with(
        path: "/subscriptions/12345/service_credits.json",
        body: {service_credit: payload}
      )
    end

    it "returns itself" do
      expect(subject.apply_service_credit(payload)).to eq subject
    end

  end

  it "makes attributes of the chargify_hash available as attributes of the object" do
    expect(subject.id).to eq 12345
    expect(subject.balance_in_cents).to eq 7654
  end

  it "sets a customer object with customer attributes" do
    customer = subject.customer
    expect(customer).to be_a(ChargifyClient::Objects::Customer)
    expect(customer.first_name).to eq "Wilma"
    expect(customer.last_name).to eq "Flintstone"
  end

  it "sets a product object with product attributes" do
    product = subject.product
    expect(product).to be_a(ChargifyClient::Objects::Product)
    expect(product.id).to eq 987
    expect(product.name).to eq "Thingamajig"
    expect(product.handle).to eq "thingy"
  end

  it "sets a product_family within product object" do
    product_family = subject.product.product_family
    expect(product_family).to be_a(ChargifyClient::Objects::ProductFamily)
    expect(product_family.id).to eq 8
    expect(product_family.name).to eq "All In"
  end

  it "sets a credit_card object with credit_card attributes" do
    credit_card = subject.credit_card
    expect(credit_card).to be_a(ChargifyClient::Objects::CreditCard)
    expect(credit_card.id).to eq 555
    expect(credit_card.masked_card_number).to eq "xxx"
  end

  context "when credit_card attribute does not exist as an attribute" do
    let(:chargify_hash) {
      {
        id: 12345,
        balance_in_cents: 7654,
        customer: {
          first_name: "Wilma",
          last_name: "Flintstone"
        },
        product: {
          id: 987,
          name: "Thingamajig",
          handle: "thingy"
        }
      }
    }

    it "returns nothing" do
      expect(subject.credit_card).to be nil
    end
  end
end
