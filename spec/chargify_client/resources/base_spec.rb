require "spec_helper"

RSpec.describe ChargifyClient::Resources::Base do
  class FooBars < described_class; end

  subject { FooBars.new(client: client) }
  let(:client) { instance_double(ChargifyClient) }
  let(:current_path) { File.expand_path(File.dirname(__FILE__)) }
  let(:resource_file_path) {
    File.join(current_path, "..", "..", "..", "lib", "chargify_client", "objects", "foo_bar.rb")
  }

  before "create a foo_bar object class" do
    File.open(resource_file_path, "w") do |file|
      file.write foo_bar_file_contents
    end
    require resource_file_path
  end

  after "remove foo_bar object class" do
    File.delete(resource_file_path) if File.exist?(resource_file_path)
  end

  describe "find_by_id" do
    before "mock client to return a foo_bar object" do
      allow(client).to receive(:get).and_return(
        {
          foo_bar: {key: "value"},
          more_info: {will: "be ignored"}
        }
      )
    end

    it "creates an object using the implementing classes name" do
      foo_bar = subject.find_by_id(7)
      expect(foo_bar).to be_a(ChargifyClient::Objects::FooBar)
    end

    it "sets objects hash by extracting the key of the implementing classes name" do
      foo_bar = subject.find_by_id(7)
      expect(foo_bar.key).to eq "value"
    end

    it "calls Chargify through the ChargifyClient" do
      subject.find_by_id(9)
      expect(client).to have_received(:get).with({path: "foo_bars/9.json"})
    end
  end

  describe "find_all" do
    before "mock client to return a foo_bar object" do
      allow(client).to receive(:get).and_return(
        [
          { foo_bar: {key: "foo_one"} },
          { foo_bar: {key: "foo_two"} }
        ]
      )
    end

    it "creates an array of objects using the implementing classes name" do
      foo_bars = subject.find_all
      expect(foo_bars).to be_a(Array)
      foo_bars.each {|foo_bar|
        expect(foo_bar).to be_a(ChargifyClient::Objects::FooBar)
      }
    end

    it "sets objects hash by extracting the key of the implementing classes name" do
      foo_bars = subject.find_all
      foo_bars.each {|foo_bar|
        value = foo_bar.key
        expect(value).not_to be_nil
        expect(["foo_one", "foo_two"]).to include(value)
      }
    end

    it "calls Chargify through the ChargifyClient" do
      subject.find_all
      expect(client).to have_received(:get).
        with(path: "foo_bars.json", params: {})
    end

    context "when params are included" do
      it "calls Chargify through the ChargifyClient including params" do
        subject.find_all(foo: "bar")
        expect(client).to have_received(:get).
          with(path: "foo_bars.json", params: {foo: "bar"})
      end

    end
  end

  describe "find_by_reference" do
    before "mock client to return a foo_bar object" do
      allow(client).to receive(:get).and_return(
        { foo_bar: {key: "found me"} }
      )
    end

    it "creates an object using the implementing classes name" do
      foo_bar = subject.find_by_reference("some_handle")
      expect(foo_bar).to be_a(ChargifyClient::Objects::FooBar)
    end

    it "sets object hash by extracting the key of the implementing classes name" do
      foo_bar = subject.find_by_reference("some_handle")
      expect(foo_bar.key).to eq "found me"
    end

    it "calls Chargify through the ChargifyClient" do
      subject.find_by_reference("some_handle")
      expect(client).to have_received(:get).
        with({path: "foo_bars/lookup.json", params: {reference: "some_handle"}})
    end
  end

  describe "create" do
    before "mock client to return a foo_bar object" do
      allow(client).to receive(:post).and_return(
        { foo_bar: {key: "created me"} }
      )
    end

    let(:payload) {
      {
        some_reference: "barney_rubble",
        some_handle: "big_boulder",
        some_attributes: {
          attr_token: "barneys_token",
          attr_other: "rocks"
        }
      }
    }

    it "returns newly created item as a chargify_client object" do
      newly_created = subject.create(payload)
      expect(newly_created).to be_a(ChargifyClient::Objects::FooBar)
      expect(newly_created.key).to eq "created me"
    end

    it "wraps the payload in the name of the object" do
      subject.create(payload)
      expect(client).to have_received(:post).
        with({path: "foo_bars.json", body: {foo_bar: payload}})
    end
  end

  def foo_bar_file_contents
    <<~CONTENTS
class ChargifyClient
  module Objects
    class FooBar < ChargifyClient::Objects::Base
    end
  end
end
    CONTENTS
  end
end
