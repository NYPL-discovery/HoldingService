require 'spec_helper'
require_relative '../../app.rb'
require_relative '../../src/http_methods.rb'

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

  swagger_event = {
    "path" => "/docs/holdings",
    "httpMethod" => "get"
  }

  mockMessage = "mockMessage"

  before do
    allow(Aws::Kinesis::Client).to receive(:new).and_return($mock_aws_kinesis)
    allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
    allow_any_instance_of(StandardError).to receive(:message).and_return(mockMessage)
    allow(self).to receive(:init).and_return(nil)
    allow($logger).to receive(:info).and_return(nil)
    allow($logger).to receive(:error).and_return(nil)
  end

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
    expect(resp).to eq(HTTPMethods.respond(200, $swagger_doc))
  end


  describe "get request" do
    get_event = {
      "path" => "",
      "httpMethod" => "GET"
    }

    mockMessage = 'mockMessage'

    before do
      allow(Aws::Kinesis::Client).to receive(:new).and_return($mock_aws_kinesis)
      allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
      allow_any_instance_of(StandardError).to receive(:message).and_return(mockMessage)
      allow(self).to receive(:init).and_return(nil)
      allow($logger).to receive(:info).and_return(nil)
      allow($logger).to receive(:error).and_return(nil)
    end

    it "should pass the event to get_holding" do
      expect(HTTPMethods).to receive(:get_holding).with(get_event)
      handle_event(event: get_event, context: nil)
    end
  end

  describe "post request" do
    post_event = {
      "path" => "",
      "httpMethod" => "POST"
    }

    mockMessage = 'mockMessage'

    before do
      allow(Aws::Kinesis::Client).to receive(:new).and_return($mock_aws_kinesis)
      allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
      allow_any_instance_of(StandardError).to receive(:message).and_return(mockMessage)
      allow(self).to receive(:init).and_return(nil)
      allow($logger).to receive(:info).and_return(nil)
      allow($logger).to receive(:error).and_return(nil)
    end

    it "should pass the event to post_holding" do
      expect(HTTPMethods).to receive(:post_holding).with(post_event)
      handle_event(event: post_event, context: nil)
    end
  end

  describe "post_holding" do
    mockMessage = 'mockMessage'

    before do
      allow(Aws::Kinesis::Client).to receive(:new).and_return($mock_aws_kinesis)
      allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
      allow_any_instance_of(StandardError).to receive(:message).and_return(mockMessage)
      allow(self).to receive(:init).and_return(nil)
      allow($logger).to receive(:info).and_return(nil)
      allow($logger).to receive(:error).and_return(nil)
    end

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

    it "should log 'handling post request'" do
      expect($logger).to receive(:info).with("handling post request")
      HTTPMethods.post_holding(correct_event)
    end

    it "should log any problem parsing JSON" do
      expect($logger).to receive(:error).with('problem parsing JSON for event', { message: mockMessage })
      resp = HTTPMethods.post_holding(malformed_json_event)
    end

    it "should respond 500 in case of malformed json" do
      resp = HTTPMethods.post_holding malformed_json_event
      expect(resp).to eq(HTTPMethods.respond(500, { message: mockMessage }))
    end

    it "should log any error from saving record" do
      expect($logger).to receive(:error).with('problem persisting records to database', { message: mockMessage })
      resp = HTTPMethods.post_holding bad_record_event
    end

    it "should respond 500 in case of error saving record" do
      resp = HTTPMethods.post_holding bad_record_event
      expect(resp).to eq(HTTPMethods.respond(500, { message: mockMessage }))
    end

    it "should save the record in case of new record" do
      resp = HTTPMethods.post_holding correct_event
      expect(Record.find_by(id: 1140039)).to be_truthy
    end

    it "should update the record in case of old record" do
      resp = HTTPMethods.post_holding updated_correct_event
      expect(Record.find_by(id: 1140039).inherit_location).to eq(true)
    end

    it "should push record to kinesis" do
      allow($kinesis_client).to receive(:<<).and_return(nil)
      expect($kinesis_client).to receive(:<<).with(JSON.parse(correct_event["body"]).first)
      HTTPMethods.post_holding correct_event
    end

    it "should log in case of error in kinesis" do
      mock_response = MockKinesisResponse.new
      allow(mock_response).to receive(:successful?).and_return(false)
      allow($mock_aws_kinesis).to receive(:put_record).and_return(mock_response)
      expect($logger).to receive(:error)
      expect($mock_aws_kinesis).to receive(:put_record)
      HTTPMethods.post_holding correct_event
    end

    it "should respond 500 in case of error in kinesis" do
      mock_response = MockKinesisResponse.new
      allow(mock_response).to receive(:successful?).and_return(false)
      allow($mock_aws_kinesis).to receive(:put_record).and_return(mock_response)
      resp = HTTPMethods.post_holding correct_event
      expect(resp).to eq(HTTPMethods.respond(500, { message: mockMessage }))
    end

    it "should respond 200 in case run is successful" do
      mock_response = MockKinesisResponse.new
      allow(mock_response).to receive(:successful?).and_return(true)
      allow($mock_aws_kinesis).to receive(:put_record).and_return(mock_response)
      resp = HTTPMethods.post_holding correct_event
      expect(resp).to eq(HTTPMethods.respond(200, { "message": "Stored #{JSON.parse(correct_event["body"]).length} records Successfully", "errors": []}))
    end
  end
end

describe "get_holding" do
  before do
    allow($logger).to receive(:info).and_return(nil)
    allow($logger).to receive(:error).and_return(nil)
  end

  it "should log 'handling get request'" do
    get_event = {}
    expect($logger).to receive(:info).with('handling get request')
    HTTPMethods.get_holding(get_event)
  end

  it "should log params" do
    get_event = {'queryStringParameters' => { 'ids' => '1'}}
    expect($logger).to receive(:info)
    expect($logger).to receive(:info).with("params: #{get_event['queryStringParameters']}")
    HTTPMethods.get_holding(get_event)
  end

  describe "missing required params" do
    it "should respond 400 with the 'missing' message" do
      get_event = {}
      expect(HTTPMethods.get_holding(get_event)).to eq(HTTPMethods.respond(400, 'Must have bib_id or ids'))
    end
  end

  describe "both ids and bib_id set" do
    it "should respond 400 with error message" do
      get_event = {"queryStringParameters" => {"ids" => "1", "bib_id" => "2"}}
      expect(HTTPMethods.get_holding(get_event)).to eq(HTTPMethods.respond(400, "Can only have one of ids, bib_id"))
    end
  end

  describe "list of bib_ids" do
    it "should respond 400 with error message" do
      get_event = {"queryStringParameters" => {"bib_id" => "2,3"}}
      expect(HTTPMethods.get_holding(get_event)).to eq(HTTPMethods.respond(400, "bib_id must be a single numerical value"))
    end
  end

  describe "getting by id" do
    it "should log 'getting by ids'" do
      expect($logger).to receive(:info)
      expect($logger).to receive(:info)
      expect($logger).to receive(:info) do |params|
        expect(params).to include("getting by ids")
      end
      HTTPMethods.get_holding({'queryStringParameters' => { 'ids' => '1'}})
    end

    it "should return record for one id that exists" do
      event = {'queryStringParameters' => { 'ids' => '1'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(1)
        expect(JSON.parse(body.first)["id"]).to eq(1)
      end
      HTTPMethods.get_holding(event)
    end

    it "should return records for two ids that exist" do
      event = {'queryStringParameters' => { 'ids' => '1,2'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(2)
        expect(JSON.parse(body.first)["id"]).to eq(1)
        expect(JSON.parse(body.second)["id"]).to eq(2)
      end
      HTTPMethods.get_holding(event)
    end

    it "should return one record for one id that exists and one that doesn't" do
      event = {'queryStringParameters' => { 'ids' => '1,4'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(1)
        expect(JSON.parse(body.first)["id"]).to eq(1)
      end
      HTTPMethods.get_holding(event)
    end

    it "should return empty array for one id that doesn't exist" do
      event = {'queryStringParameters' => { 'ids' => '4'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(0)
      end
      HTTPMethods.get_holding(event)
    end

    it "should log responding 200" do
      event = {'queryStringParameters' => { 'ids' => '4'}}
      expect($logger).to receive(:info).with("responding 200")
      HTTPMethods.get_holding(event)
    end
  end

  describe "getting by bib_id" do
    it "should log 'getting by bib_id'" do
      expect($logger).to receive(:info)
      expect($logger).to receive(:info)
      expect($logger).to receive(:info) do |params|
        expect(params).to include("getting by bib_id")
      end
      HTTPMethods.get_holding({'queryStringParameters' => { 'bib_id' => '1'}})
    end

    it "should return record for one id that exists" do
      event = {'queryStringParameters' => { 'bib_id' => '1'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(1)
        expect(JSON.parse(body.first)["id"]).to eq(1)
      end
      HTTPMethods.get_holding(event)
    end

    it "should return records for one id that exists multiple times" do
      event = {'queryStringParameters' => { 'bib_id' => '3'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(2)
        expect(JSON.parse(body.first)["id"]).to eq(1)
        expect(JSON.parse(body.second)["id"]).to eq(2)
      end
      HTTPMethods.get_holding(event)
    end

    it "should return empty array for one id that doesn't exist" do
      event = {'queryStringParameters' => { 'bib_id' => '7'}}
      expect(HTTPMethods).to receive(:respond) do |*params|
        expect(params[0]).to eq(200)
        body = params[1]
        expect(body.length).to eq(0)
      end
      HTTPMethods.get_holding(event)
    end

    it "should log responding 200" do
      event = {'queryStringParameters' => { 'bib_id' => '4'}}
      expect($logger).to receive(:info).with("responding 200")
      HTTPMethods.get_holding(event)
    end
  end

  describe 'db error' do
    message = "problem getting records with ids: 1, message: Mock Error Message"
    it 'should log the params and error' do
      allow($logger).to receive(:info).with("responding 200").and_raise(StandardError.new("Mock Error Message"))
      expect($logger).to receive(:error).with(message)
      HTTPMethods.get_holding({'queryStringParameters' => {'ids' => '1'}})
    end

    it 'should respond 500 with error message' do
      allow($logger).to receive(:info).with("responding 200").and_raise(StandardError.new("Mock Error Message"))
      expect(HTTPMethods.get_holding({'queryStringParameters' => {'ids' => '1'}})).to eq(HTTPMethods.respond(500, message))
    end
  end
end
