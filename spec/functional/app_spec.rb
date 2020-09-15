require 'spec_helper'
require_relative '../../app.rb'

describe 'HoldingService' do
  before(:each) do
    $logger = double(:debug => nil, :info => nil, :warn => nil, :error => nil)
    allow_any_instance_of(NYPLRubyUtil::KinesisClient).to receive(:<<)
    allow_any_instance_of(NYPLRubyUtil::KmsClient).to receive(:decrypt).and_return('')
  end

  malformed_json_event = {
    "path" => "/holdings",
    "httpMethod" => "POST",
    "body" => "fkajskajsd"
  }

  bad_record_event = {
    "path" => "/holdings",
    "httpMethod" => "POST",
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

  describe 'POST /holding' do
    it "should respond 500 in case of malformed json" do
      resp = handle_event(event: malformed_json_event, context: {})

      expect(resp[:statusCode]).to eq(500)
      expect(resp[:body]).to include('unexpected token')
    end
  
    it "should respond 500 in case of error saving record" do
      resp = handle_event(event: bad_record_event, context: {})

      expect(resp[:statusCode]).to eq(500)
      expect(resp[:body]).to include('PG::SyntaxError')
    end

    it "should save the record in case of new record" do
      expect_any_instance_of(NYPLRubyUtil::KinesisClient).to receive(:<<).with(JSON.parse(correct_event["body"]).first)
      resp = handle_event(event: correct_event, context: {})
      expect(Record.find_by(id: 1140039)).to be_truthy
    end

    it "should update the record in case of old record" do
      expect_any_instance_of(NYPLRubyUtil::KinesisClient).to receive(:<<).with(JSON.parse(updated_correct_event["body"]).first)
      resp = handle_event(event: updated_correct_event, context: {})
      expect(Record.find_by(id: 1140039).inheritLocation).to eq(true)
    end
  end

  describe 'GET /holdings' do
    describe 'with ids as query parameter' do
      it "should return record for one id that exists" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'ids' => '1'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})
  
        expect(resp[:statusCode]).to eq(200)
        expect(JSON.parse(resp[:body]).first['id']).to eq(1)
      end
  
      it "should return records for two ids that exist" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'ids' => '1,2'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})
  
        expect(resp[:statusCode]).to eq(200)
        resp_records = JSON.parse(resp[:body])
        expect(resp_records.first['id']).to eq(1)
        expect(resp_records.second['id']).to eq(2)
      end
  
      it "should return one record for one id that exists and one that doesn't" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'ids' => '1,4'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})
  
        expect(resp[:statusCode]).to eq(200)
        resp_records = JSON.parse(resp[:body])
        expect(resp_records.length).to eq(1)
        expect(resp_records.first['id']).to eq(1)
      end
  
      it "should return empty array for one id that doesn't exist" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'ids' => '4'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})

        expect(resp[:statusCode]).to eq(200)
        expect(JSON.parse(resp[:body]).length).to eq(0)
      end
    end

    describe 'with bib_id as query parameter' do
      it "should return record for one id that exists" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'bib_id' => '1'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})
  
        expect(resp[:statusCode]).to eq(200)

        resp_records = JSON.parse(resp[:body])
        expect(resp_records.length).to eq(1)
        expect(resp_records.first['id']).to eq(1)
      end

      it "should return records for one id that exists multiple times" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'bib_id' => '3'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})

        expect(resp[:statusCode]).to eq(200)

        resp_records = JSON.parse(resp[:body])
        expect(resp_records.first['id']).to eq(1)
        expect(resp_records.second['id']).to eq(2)
      end

      it "should return empty array for one id that doesn't exist" do
        event = {
          'path' => '/holdings',
          'httpMethod' => 'GET',
          'queryStringParameters' => { 'bib_id' => '7'},
          'pathParameters' => {}
        }
        resp = handle_event(event: event, context: {})

        expect(resp[:statusCode]).to eq(200)
        expect(JSON.parse(resp[:body]).length).to eq(0)
      end
    end
  end
  
  describe 'GET /holdings/{id}' do
    it 'should return a single record object if found' do
      event = {
        'path' => '/holdings/1',
        'httpMethod' => 'GET',
        'queryStringParameters' => {},
        'pathParameters' => { 'id' => '1' }
      }
      resp = handle_event(event: event, context: {})

      expect(resp[:statusCode]).to eq(200)
      resp_record = JSON.parse(resp[:body])
      expect(resp_record['id']).to eq(1)
    end

    it 'should return a 404 message if record not found' do
      event = {
        'path' => '/holdings/5',
        'httpMethod' => 'GET',
        'queryStringParameters' => {},
        'pathParameters' => { 'id' => '5' }
      }
      resp = handle_event(event: event, context: {})

      expect(resp[:statusCode]).to eq(404)
      resp_record = JSON.parse(resp[:body])
      expect(resp_record).to eq('No record exists with id 5')
    end
  end

  describe 'GET /docs/holdings' do
    it 'should return the swagger documentation' do
      event = {
        'path' => '/docs/holdings',
        'httpMethod' => 'GET',
        'queryStringParameters' => {},
        'pathParameters' => {}
      }

      resp = handle_event(event: event, context: {})
      resp_record = JSON.parse(resp[:body])

      expect(resp_record['swagger']).to eq('2.0')
      expect(resp_record['info']['title']).to eq('Holding Service')
    end
  end
end
