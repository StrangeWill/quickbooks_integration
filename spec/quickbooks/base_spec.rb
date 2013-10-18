require "spec_helper"

describe Quickbooks::Base do

  context ".client" do
    it "raise InvalidPlatformException when config has invalid platform" do
      expect {
        Quickbooks::Base.client({},"",{"quickbooks.platform" => "smoke"})
      }.to raise_error(Quickbooks::InvalidPlatformException, /We cannot create the/)
    end

    it "initializes the correct platform client" do
      client = Quickbooks::Base.client({},"",{"quickbooks.platform" => "online"})
      client.class.should eql Quickbooks::Online::Client
    end
  end

  context "#get_config!" do
    it "raises an exception when the key is not present in the config" do
      expect {
        Quickbooks::Base.new({},"",{},"").get_config!("bla")
      }.to raise_error(Quickbooks::LookupValueNotFoundException, /Can't find the key/)
    end
  end

  context "#payment_method_name" do

    let(:payload) {
      {"original" => Factories.original}
    }

    let(:client_base) {
        Quickbooks::Base.new(payload,"",{},"")
    }

    context "with credit_card" do
      it "returns the cc_type when there is a credit_card" do
        client_base.payment_method_name.should eql "visa"
      end
    end

    context "with no credit_card present" do

      let(:payload) {
        {"original" => Factories.original.tap{ |x| x.delete("credit_cards")} }
      }

      it "returns the payment_method name when no credit_card present" do
        client_base.payment_method_name.should eql "Check"
      end
    end

    context "with no payments present" do
      let(:payload) {
        {"original" => Factories.original.tap{ |x| x.delete("credit_cards")}.tap{|x|x.delete("payments")} }
      }

      it "returns 'None' as payment_method_name" do
        client_base.payment_method_name.should eql "None"
      end
    end
  end

  context "Quickeebooks dynamics" do

    let(:config) {
      {
        'quickbooks.realm' => "abc",
        'quickbooks.access_token' => "23243fdsfser23t4gs",
        'quickbooks.access_secret' => "abc23refsv32rfwe",
        'quickbooks.platform' => "online"
      }
    }

    let(:client) { Quickbooks::Base.client({},"",config) }

    context "#create_service" do
      it "returns the service instance based on platform" do
        client.create_service("Customer").class.should eql Quickeebooks::Online::Service::Customer
      end

      it "raises an exception when the platform does not support the service" do
        expect {
          client.status_service
        }.to raise_error(Quickbooks::UnsupportedException, "status_service is not supported for Quickbooks Online")
      end
    end

    context "#create_model" do
      it "returns the model instance based on platform" do
        client.create_model("Address").class.should eql Quickeebooks::Online::Model::Address
      end
    end

  end
end