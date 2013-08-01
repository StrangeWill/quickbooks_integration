require 'spec_helper'

describe QuickbooksEndpoint do

  def auth
    {'HTTP_X_AUGURY_TOKEN' => 'x123'}
  end

  def app
    described_class
  end

  let(:params) { {'store_id' => '123229227575e4645c000001',
                  'payload' => { 'parameters' => Factories.parameters,
                                 'order' => { 'actual' => Factories.order },
                                 'shipment_number' => 'H438105531460' },
                  'message_id' => 'abc'  } }


  it "should respond to POST /import" do
    OrderImporter.should_receive(:new).with(anything, anything, anything).and_return(mock(:consume => {}))
    post '/import', params.to_json, auth
    last_response.should be_ok
  end

  it "should respond to POST /update" do
    OrderUpdater.should_receive(:new).with(anything, anything, anything).and_return(mock(:consume => {}))
    post '/update', params.to_json, auth
    last_response.should be_ok
  end
end
