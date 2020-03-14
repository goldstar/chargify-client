require "spec_helper"
require "chargify_client/resources/subscriptions"

RSpec.describe ChargifyClient::Resources::Subscriptions do
  let(:client) { ChargifyClient.new(
    api_key: "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", subdomain: "goldstar-acme"
  )}

  describe "find_all", vcr: { cassette_name: "subscriptions" } do
    subject { client.subscriptions.find_all }

    it "returns a collection of subscriptions" do
      expect(subject.length).to eq 9
      subject.each {|subscription|
        expect(subscription).to be_a(ChargifyClient::Objects::Subscription)
      }
    end

    it "sets customers on each subscription" do
      subject.each {|subscription|
        expect(subscription.customer).to be_a(ChargifyClient::Objects::Customer)
      }
    end
  end

end
