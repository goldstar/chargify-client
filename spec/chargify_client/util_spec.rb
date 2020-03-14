require "spec_helper"

RSpec.describe ChargifyClient::Util do
  let!(:client) { ChargifyClient.new(api_key: "key", subdomain: "subdomain") }

  describe "create_new_resources" do
    it "instantiates the corresponding class from chargify_client/resources" do
      expect(described_class.create_new_resources("Customers", client)).
        to be_a(ChargifyClient::Resources::Customers)
    end

    it "is case insensitive" do
      expect(described_class.create_new_resources("customers", client)).
        to be_a(ChargifyClient::Resources::Customers)
    end

    it "accepts snake_case class names" do
      # Since their isn't a "resources" class with a compound name as of the time
      # this test was written, we're going to cause an error that will show that
      # "this_will_be_fixed" becomes "ChargifyClient::Resources::ThisWillBeFixed"
      expect { described_class.create_new_resources("this_will_be_fixed", client) }.
        to raise_error(/ThisWillBeFixed/)
    end

    it "is raises an error if corresponding class does not exist" do
      expect { described_class.create_new_resources("not_gonna_find_me", client) }.
        to raise_error(NameError)
    end
  end

  describe "create_new_object" do
    it "instantiates the corresponding class from chargify_client/resources" do
      expect(described_class.create_new_object("Subscription", client, {})).
        to be_a(ChargifyClient::Objects::Subscription)
    end

    it "is case insensitive" do
      expect(described_class.create_new_object("subscription", client, {})).
        to be_a(ChargifyClient::Objects::Subscription)
    end

    it "passes args as chargify_hash" do
      sub = described_class.create_new_object("subscription", client, {foo: "bar"})
      expect(sub.foo).to eq "bar"
    end

    it "is raises an error if corresponding class does not exist" do
      expect { described_class.create_new_object("not_gonna_find_me", client) }.
        to raise_error(NameError)
    end
  end

  describe "create_new" do
    it "instantiates objects with arguments" do
      new_object = described_class.create_new("Random", 7)
      expect(new_object).to be_a Random
      expect(new_object.seed).to eq 7
    end

    it "instantiates objects without arguments" do
      new_object = described_class.create_new("ChargifyClient::Util", nil)
      expect(new_object).to be_a ChargifyClient::Util
    end

    context "when class name is nested and arguments are named" do
      class ExampleClass
        class Deeply
          class Nested
            attr_accessor :arg1, :arg2
            def initialize(arg1:, arg2:)
              @arg1 = arg1
              @arg2 = arg2
            end
          end
        end
      end

      it "creates the object as expected" do
        new_object = described_class.create_new(
          "ExampleClass::Deeply::Nested", {arg1: "one", arg2: "two"}
        )
        expect(new_object).to be_a ExampleClass::Deeply::Nested
        expect(new_object.arg1).to eq "one"
        expect(new_object.arg2).to eq "two"
      end
    end
  end
end
