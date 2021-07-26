require 'spec_helper'
require_relative '../../src/http_methods.rb'

describe HTTPMethods do
    before do
        $logger = double(:debug => nil, :info => nil, :warn => nil, :error => nil)
    end

    describe :get_holdings_req do
        it 'should invoke get_holding if pathParameter provided' do
            expect(HTTPMethods).to receive(:get_holding).with(1).and_return('test_single_holding')

            res = HTTPMethods.get_holdings_req({ 'pathParameters' => { 'id' => 1 } })

            expect(res).to eq('test_single_holding')
        end

        it 'should invoke get_holdings if queryStringParameters are present' do
            string_params = {
                'queryStringParameters' => {
                    'ids' => '1,2,3'
                }
            }
            expect(HTTPMethods).to receive(:get_holdings).with(string_params['queryStringParameters']).and_return('test_multi_holdings')

            res = HTTPMethods.get_holdings_req(string_params)

            expect(res).to eq('test_multi_holdings')
        end
    end

    describe :get_holding do
        it 'should respond with 200 status if successfully found matching record' do
            expect(Record).to receive(:find_by).with(id: 1).and_return({ 'record': 'test_record' })
            expect(HTTPMethods).to receive(:respond).with(200, { :record => 'test_record' }).and_return(200)

            res = HTTPMethods.get_holding(1)

            expect(res).to eq(200)
        end

        it 'should respond with 404 status if no matching record found' do
            expect(Record).to receive(:find_by).with(id: 1).and_return(nil)
            expect(HTTPMethods).to receive(:respond).with(404, 'No record exists with id 1').and_return(404)

            res = HTTPMethods.get_holding(1)

            expect(res).to eq(404)
        end

        it 'should respond with 500 status if database error encountered' do
            expect(Record).to receive(:find_by).with(id: 1).and_raise(StandardError, 'Test Error')
            expect(HTTPMethods).to receive(:respond).with(500, 'Unable to retrieve record 1 with message Test Error').and_return(500)

            res = HTTPMethods.get_holding(1)

            expect(res).to eq(500)
        end
    end

    describe :get_holdings do
        it 'should return error statement if params are malformed' do
            test_params = { 'wrong_id' => '1' }
            expect(HTTPMethods).to receive(:check_for_param_errors).with(test_params).and_return('ERROR')

            res = HTTPMethods.get_holdings(test_params)

            expect(res).to eq('ERROR')
        end

        it 'should return 200 if query with ids is successful' do
            test_params = { 'ids' => '1,2,3' }
            expect(HTTPMethods).to receive(:check_for_param_errors).with(test_params).and_return(nil)
            expect(Record).to receive(:where).with('id IN (1,2,3)').and_return([
                { 'test' => 1 }, { 'test' => 2 }, { 'test' => 3 }
            ])
            expect(HTTPMethods).to receive(:respond).with(200, [
                {'test' => 1}, {'test' => 2 }, {'test' => 3}
            ]).and_return(200)

            res = HTTPMethods.get_holdings(test_params)

            expect(res).to eq(200)
        end

        it 'should return 200 if query with bib_id is successful' do
            test_params = { 'bib_id' => '1' }
            expect(HTTPMethods).to receive(:check_for_param_errors).with(test_params).and_return(nil)
            expect(Record).to receive(:where).with('\'{1}\' && "bibIds"').and_return([
                { 'test' => 1 }, { 'test' => 2 }, { 'test' => 3 }
            ])
            expect(HTTPMethods).to receive(:respond).with(200, [
                { 'test' => 1 }, { 'test' => 2 }, { 'test' => 3 }
            ]).and_return(200)

            res = HTTPMethods.get_holdings(test_params)

            expect(res).to eq(200)
        end

        it 'should return 200 if query with bib_ids is successful' do
            test_params = { 'bib_ids' => '1,2,3' }
            expect(HTTPMethods).to receive(:check_for_param_errors).with(test_params).and_return(nil)
            expect(Record).to receive(:where).with('\'{1,2,3}\' && "bibIds"').and_return([
                { 'test' => 1 }, { 'test' => 2 }, { 'test' => 3 }
            ])
            expect(HTTPMethods).to receive(:respond).with(200, [
                { 'test' => 1 }, { 'test' => 2 }, { 'test' => 3 }
            ]).and_return(200)

            res = HTTPMethods.get_holdings(test_params)

            expect(res).to eq(200)
        end

        it 'should return 500 if query is unsuccessful' do
            test_params = { 'bib_id' => '1' }
            expect(HTTPMethods).to receive(:check_for_param_errors).with(test_params).and_return(nil)
            expect(Record).to receive(:where).with('\'{1}\' && "bibIds"').and_raise(StandardError, 'Test Error')
            expect(HTTPMethods).to receive(:respond).with(500, 'problem getting records with query: 1 = ANY("bibIds"), message: Test Error').and_return(500)

            res = HTTPMethods.get_holdings(test_params)

            expect(res).to eq(500)
        end
    end

    describe :check_for_param_errors do
        it 'should return nil if params conform to expectations' do
            expect(HTTPMethods.check_for_param_errors({ 'ids' => '1,2,3' })).to eq(nil)
        end

        it 'should return 400 error if params don\'t any keys' do
            expect(HTTPMethods).to receive(:respond).with(400, 'Must have bib_id or ids').and_return(400)
            expect(HTTPMethods.check_for_param_errors({})).to eq(400)
        end

        it 'should return 400 error if params have both ids and bib_id' do
            expect(HTTPMethods).to receive(:respond).with(400, 'Can only have one of ids, bib_id').and_return(400)
            expect(HTTPMethods.check_for_param_errors({ 'ids' => '1,3', 'bib_id' => '2' })).to eq(400)
        end

        it 'should return 400 error if bib_id contains an array of identifiers' do
            expect(HTTPMethods).to receive(:respond).with(400, 'bib_id must be a single numerical value').and_return(400)
            expect(HTTPMethods.check_for_param_errors({ 'bib_id' => '1,2' })).to eq(400)
        end

        it 'should return 400 error if bib_ids contains invalid characters' do
            expect(HTTPMethods).to receive(:respond).with(400, 'bib_ids must contain comma-delimited numerical values').and_return(400)
            expect(HTTPMethods.check_for_param_errors({ 'bib_ids' => '1,2,abc' })).to eq(400)
        end
    end

    describe :post_holding do
        before do
            $kinesis_client = double(:<< => nil)
        end

        it 'should return 200 if record is successfully stored in database and sent to kinesis' do
            expect(Record).to receive(:upsert_all).with([{"id" => 1}], unique_by: :id)
            expect($kinesis_client).to receive(:<<).with({ 'id' => 1 })
            expect(HTTPMethods).to receive(:respond).with(200, {:errors => [], :message => 'Stored 1 records Successfully'}).and_return(200)

            res = HTTPMethods.post_holding({
                'body' => '[{"id":1}]'
            })

            expect(res).to eq(200)
        end

        it 'should return 500 if unable to load JSON from event body' do
            expect(JSON).to receive(:parse).with('[{"id": 1}]').and_raise(StandardError, 'Test JSON Error')
            expect(HTTPMethods).to receive(:respond).with(500, { message: 'Test JSON Error' }).and_return(500)

            res = HTTPMethods.post_holding({
                'body' => '[{"id": 1}]'
            })

            expect(res).to eq(500)
        end

        it 'should return 500 if unable to persist record in database' do
            expect(Record).to receive(:upsert_all).with([{ "id" => 1 }], unique_by: :id).and_raise(StandardError, 'Test DB Error')
            expect(HTTPMethods).to receive(:respond).with(500, { message: 'Test DB Error'}).and_return(500)

            res = HTTPMethods.post_holding({
                'body' => '[{"id":1}]'
            })

            expect(res).to eq(500)
        end

        it 'should return 500 if unable to send processed records to kinesis stream' do
            expect(Record).to receive(:upsert_all).with([{ "id" => 1 }], unique_by: :id)
            expect($kinesis_client).to receive(:<<).with({ 'id' => 1 }).and_raise(StandardError, 'Test Kinesis Error')
            expect(HTTPMethods).to receive(:respond).with(500, { message: 'Test Kinesis Error' }).and_return(500)

            res = HTTPMethods.post_holding({
                'body' => '[{"id":1}]'
            })

            expect(res).to eq(500)
        end
    end

    describe :respond do
        it 'should return object with status code and JSON body' do
            res = HTTPMethods.respond(200, { 'test' => 'response' })

            expect(res[:statusCode]).to eq(200)
            expect(res[:body]).to eq('{"test":"response"}')
            expect(res[:headers][:'Content-type']).to eq('application/json')
        end
    end
end
