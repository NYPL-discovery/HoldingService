require 'spec_helper'
require_relative '../../app.rb'

$mock_aws_kinesis = MockAwsKinesisClient.new

describe 'init' do
  before do
    allow(Aws::Kinesis::Client).to receive(:initialize).and_return($mock_aws_kinesis)
  end

  it 'should initialize db connection' do
    allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
    expect(ActiveRecord::Base).to receive(:establish_connection)
    init
  end

  it "should initialize logger" do
    expect($logger.class).to eq(NYPLRubyUtil::NyplLogFormatter)
  end

  it "should initialize db_fields" do
    expect($db_fields.class).to eq(Hash)
  end

  it "should initialize kinesis_client" do
    expect($kinesis_client.class).to eq(NYPLRubyUtil::KinesisClient)
  end

  it "should initialize swagger doc" do
    expect($swagger_doc.class).to eq(Hash)
  end

end

describe "handle_event" do

  mockMessage = 'mockMessage'

  before do
    allow(Aws::Kinesis::Client).to receive(:new).and_return($mock_aws_kinesis)
    allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
    allow_any_instance_of(StandardError).to receive(:message).and_return(mockMessage)
    allow(self).to receive(:init).and_return(nil)
    allow($logger).to receive(:info).and_return(nil)
    allow($logger).to receive(:error).and_return(nil)
  end

  swagger_event = {
    "path" => "/docs/holding",
    "httpMethod" => "get"
  }

  malformed_json_event = {
    "path" => "",
    "httpMethod" => "",
    "body" => "fkajskajsd"
  }

  bad_record_event = {
    "path" => "",
    "httpMethod" => "",
    "body" => "[{}]"
  }

  correct_event = {
    "resource" => "/api/v0.1/holdings",
    "path" => "/api/v0.1/holdings",
    "httpMethod" => "POST",
    "body" => "[{\"id\":1140039,\"bibIds\":[17058685],\"bibIdLinks\":[\"https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/bibs/17058685\"],\"itemIds\":[],\"itemIdLinks\":[],\"inheritLocation\":false,\"allocationRule\":null,\"accountingUnit\":1,\"labelCode\":\"n\",\"serialCode1\":\"a\",\"serialCode2\":\"-\",\"serialCode3\":\"-\",\"serialCode4\":\"-\",\"claimOnDate\":\"2020-06-07T04:00:00Z\",\"receivingLocationCode\":\"16\",\"vendorCode\":\"none\",\"updateCount\":\"-\",\"pieceCount\":0,\"eCheckInCode\":\" \",\"mediaTypeCode\":\" \",\"updatedDate\":\"2020-03-23T13:22:02Z\",\"createdDate\":\"2020-03-23T13:14:50Z\",\"deletedDate\":null,\"deleted\":false,\"suppressed\":false,\"fixedFields\":{\"35\":{\"label\":\"Label Type\",\"value\":\"n\",\"display\":null},\"36\":{\"label\":\"Serial Code 1\",\"value\":\"a\",\"display\":null},\"37\":{\"label\":\"Serial Code 2\",\"value\":\"-\",\"display\":null},\"38\":{\"label\":\"Copies\",\"value\":\"1\",\"display\":null},\"39\":{\"label\":\"Claim On\",\"value\":\"2020-06-07\",\"display\":null},\"40\":{\"label\":\"Location\",\"value\":\"mak  \",\"display\":null},\"41\":{\"label\":\"Recv Location\",\"value\":\"16 \",\"display\":null},\"42\":{\"label\":\"Vendor\",\"value\":\"none \",\"display\":null},\"80\":{\"label\":\"Record Type\",\"value\":\"c\",\"display\":null},\"81\":{\"label\":\"Record Number\",\"value\":\"1140039\",\"display\":null},\"83\":{\"label\":\"Created Date\",\"value\":\"2020-03-23T13:14:50Z\",\"display\":null},\"84\":{\"label\":\"Updated Date\",\"value\":\"2020-03-23T13:22:02Z\",\"display\":null},\"85\":{\"label\":\"No. of Revisions\",\"value\":\"2\",\"display\":null},\"86\":{\"label\":\"Agency\",\"value\":\"1\",\"display\":null},\"98\":{\"label\":\"PDATE\",\"value\":\"2020-03-23T13:14:00Z\",\"display\":null},\"118\":{\"label\":\"Serial Code 3\",\"value\":\"-\",\"display\":null},\"119\":{\"label\":\"Serial Code 4\",\"value\":\"-\",\"display\":null},\"120\":{\"label\":\"Update Count\",\"value\":\"-\",\"display\":null},\"121\":{\"label\":\"Piece Count\",\"value\":\"0\",\"display\":null},\"137\":{\"label\":\"E-Checkin\",\"value\":\" \",\"display\":null},\"159\":{\"label\":\"Media Type\",\"value\":\" \",\"display\":null},\"266\":{\"label\":\"Inherit Location\",\"value\":\"false\",\"display\":null}},\"varFields\":[{\"fieldTag\":\"_\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"00000ny   22000003n 4500\",\"subfields\":null},{\"fieldTag\":\"h\",\"marcTag\":\"863\",\"ind1\":\" \",\"ind2\":\" \",\"content\":null,\"subfields\":[{\"tag\":\"8\",\"content\":\"1.1\"},{\"tag\":\"a\",\"content\":\"1-3\"},{\"tag\":\"i\",\"content\":\"2020\"},{\"tag\":\"j\",\"content\":\"01-03\"},{\"tag\":\"k\",\"content\":\"15\"}]},{\"fieldTag\":\"i\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"TEST IDENTITY\",\"subfields\":null},{\"fieldTag\":\"n\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"Public note\",\"subfields\":null},{\"fieldTag\":\"y\",\"marcTag\":\"853\",\"ind1\":\" \",\"ind2\":\" \",\"content\":null,\"subfields\":[{\"tag\":\"8\",\"content\":\"1\"},{\"tag\":\"a\",\"content\":\"no.\"},{\"tag\":\"i\",\"content\":\"(year)\"},{\"tag\":\"j\",\"content\":\"(month)\"},{\"tag\":\"k\",\"content\":\"(day)\"}]},{\"fieldTag\":\"z\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"INTERNAL NOTE\",\"subfields\":null}],\"location\":{\"code\":\"mak\",\"label\":\"Schwarzman Building - Dewitt Wallace Room 108\"},\"holdings\":[]}]",
    "isBase64Encoded": false
  }

  updated_correct_event = {
    "resource" => "/api/v0.1/holdings",
    "path" => "/api/v0.1/holdings",
    "httpMethod" => "POST",
    "body" => "[{\"id\":1140039,\"bibIds\":[17058685],\"bibIdLinks\":[\"https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/bibs/17058685\"],\"itemIds\":[],\"itemIdLinks\":[],\"inheritLocation\":true,\"allocationRule\":null,\"accountingUnit\":1,\"labelCode\":\"n\",\"serialCode1\":\"a\",\"serialCode2\":\"-\",\"serialCode3\":\"-\",\"serialCode4\":\"-\",\"claimOnDate\":\"2020-06-07T04:00:00Z\",\"receivingLocationCode\":\"16\",\"vendorCode\":\"none\",\"updateCount\":\"-\",\"pieceCount\":0,\"eCheckInCode\":\" \",\"mediaTypeCode\":\" \",\"updatedDate\":\"2020-03-23T13:22:02Z\",\"createdDate\":\"2020-03-23T13:14:50Z\",\"deletedDate\":null,\"deleted\":false,\"suppressed\":false,\"fixedFields\":{\"35\":{\"label\":\"Label Type\",\"value\":\"n\",\"display\":null},\"36\":{\"label\":\"Serial Code 1\",\"value\":\"a\",\"display\":null},\"37\":{\"label\":\"Serial Code 2\",\"value\":\"-\",\"display\":null},\"38\":{\"label\":\"Copies\",\"value\":\"1\",\"display\":null},\"39\":{\"label\":\"Claim On\",\"value\":\"2020-06-07\",\"display\":null},\"40\":{\"label\":\"Location\",\"value\":\"mak  \",\"display\":null},\"41\":{\"label\":\"Recv Location\",\"value\":\"16 \",\"display\":null},\"42\":{\"label\":\"Vendor\",\"value\":\"none \",\"display\":null},\"80\":{\"label\":\"Record Type\",\"value\":\"c\",\"display\":null},\"81\":{\"label\":\"Record Number\",\"value\":\"1140039\",\"display\":null},\"83\":{\"label\":\"Created Date\",\"value\":\"2020-03-23T13:14:50Z\",\"display\":null},\"84\":{\"label\":\"Updated Date\",\"value\":\"2020-03-23T13:22:02Z\",\"display\":null},\"85\":{\"label\":\"No. of Revisions\",\"value\":\"2\",\"display\":null},\"86\":{\"label\":\"Agency\",\"value\":\"1\",\"display\":null},\"98\":{\"label\":\"PDATE\",\"value\":\"2020-03-23T13:14:00Z\",\"display\":null},\"118\":{\"label\":\"Serial Code 3\",\"value\":\"-\",\"display\":null},\"119\":{\"label\":\"Serial Code 4\",\"value\":\"-\",\"display\":null},\"120\":{\"label\":\"Update Count\",\"value\":\"-\",\"display\":null},\"121\":{\"label\":\"Piece Count\",\"value\":\"0\",\"display\":null},\"137\":{\"label\":\"E-Checkin\",\"value\":\" \",\"display\":null},\"159\":{\"label\":\"Media Type\",\"value\":\" \",\"display\":null},\"266\":{\"label\":\"Inherit Location\",\"value\":\"false\",\"display\":null}},\"varFields\":[{\"fieldTag\":\"_\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"00000ny   22000003n 4500\",\"subfields\":null},{\"fieldTag\":\"h\",\"marcTag\":\"863\",\"ind1\":\" \",\"ind2\":\" \",\"content\":null,\"subfields\":[{\"tag\":\"8\",\"content\":\"1.1\"},{\"tag\":\"a\",\"content\":\"1-3\"},{\"tag\":\"i\",\"content\":\"2020\"},{\"tag\":\"j\",\"content\":\"01-03\"},{\"tag\":\"k\",\"content\":\"15\"}]},{\"fieldTag\":\"i\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"TEST IDENTITY\",\"subfields\":null},{\"fieldTag\":\"n\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"Public note\",\"subfields\":null},{\"fieldTag\":\"y\",\"marcTag\":\"853\",\"ind1\":\" \",\"ind2\":\" \",\"content\":null,\"subfields\":[{\"tag\":\"8\",\"content\":\"1\"},{\"tag\":\"a\",\"content\":\"no.\"},{\"tag\":\"i\",\"content\":\"(year)\"},{\"tag\":\"j\",\"content\":\"(month)\"},{\"tag\":\"k\",\"content\":\"(day)\"}]},{\"fieldTag\":\"z\",\"marcTag\":null,\"ind1\":null,\"ind2\":null,\"content\":\"INTERNAL NOTE\",\"subfields\":null}],\"location\":{\"code\":\"mak\",\"label\":\"Schwarzman Building - Dewitt Wallace Room 108\"},\"holdings\":[]}]",
    "isBase64Encoded": false
  }

  it "should call init" do
    expect(self).to receive(:init)
    handle_event(event: swagger_event, context: nil)
  end

  it "should log the event" do
    expect($logger).to receive(:info).with('handling event ', swagger_event)
    handle_event(event: swagger_event, context: nil)
  end

  it "should respond with swagger doc in case of swagger doc path" do
    resp = handle_event(event: swagger_event, context: nil)
    expect(resp).to eq(respond(200, $swagger_doc))
  end

  it "should log any problem parsing JSON" do
    expect($logger).to receive(:error).with('problem parsing JSON for event', { message: mockMessage })
    resp = handle_event(event: malformed_json_event, context: nil)
  end

  it "should respond 500 in case of malformed json" do
    resp = handle_event(event: malformed_json_event, context: nil)
    expect(resp).to eq(respond(500, { message: mockMessage }))
  end

  it "should log any error from saving record" do
    expect($logger).to receive(:error).with('problem persisting records to database', { message: mockMessage })
    resp = handle_event(event: bad_record_event, context: nil)
  end

  it "should respond 500 in case of error saving record" do
    resp = handle_event(event: bad_record_event, context: nil)
    expect(resp).to eq(respond(500, { message: mockMessage }))
  end

  it "should save the record in case of new record" do
    resp = handle_event(event: correct_event, context: nil)
    expect(Record.find_by(id: 1140039)).to be_truthy
  end

  it "should update the record in case of old record" do
    resp = handle_event(event: updated_correct_event, context: nil)
    expect(Record.find_by(id: 1140039).inherit_location).to eq(true)
  end

  it "should push record to kinesis" do
    allow($kinesis_client).to receive(:<<).and_return(nil)
    expect($kinesis_client).to receive(:<<).with(JSON.parse(correct_event["body"]).first)
    handle_event(event: correct_event, context: nil)
  end

  it "should log in case of error in kinesis" do
    mock_response = MockKinesisResponse.new
    allow(mock_response).to receive(:successful?).and_return(false)
    allow($mock_aws_kinesis).to receive(:put_record).and_return(mock_response)
    expect($logger).to receive(:error)
    expect($mock_aws_kinesis).to receive(:put_record)
    handle_event(event: correct_event, context: nil)
  end

  it "should respond 500 in case of error in kinesis" do
    mock_response = MockKinesisResponse.new
    allow(mock_response).to receive(:successful?).and_return(false)
    allow($mock_aws_kinesis).to receive(:put_record).and_return(mock_response)
    resp = handle_event(event: correct_event, context: nil)
    expect(resp).to eq(respond(500, { message: mockMessage }))
  end

  it "should respond 200 in case run is successful" do
    mock_response = MockKinesisResponse.new
    allow(mock_response).to receive(:successful?).and_return(true)
    allow($mock_aws_kinesis).to receive(:put_record).and_return(mock_response)
    resp = handle_event(event: correct_event, context: nil)
    expect(resp).to eq(respond(200))
  end
end
