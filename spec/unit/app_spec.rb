require 'spec_helper'
require_relative '../../app.rb'

describe 'app' do
    describe :init do
        it 'should invoke KMS Client, ActiveRecord Kinesis client and load swagger docs' do
            kms_double = double(:decrypt => 'test_pswd')
            expect(NYPLRubyUtil::KmsClient).to receive(:new).and_return(kms_double)
            logger_double = double(:info => nil)
            expect(NYPLRubyUtil::NyplLogFormatter).to receive(:new).with(STDOUT, level: 'info').and_return(logger_double)
            expect(ActiveRecord::Base).to receive(:establish_connection).with(
                adapter: 'postgresql',
                database: 'test_holdings',
                host: 'localhost',
                username: 'postgres',
                password: 'test_pswd'
            )
            expect(NYPLRubyUtil::KinesisClient).to receive(:new).and_return('mock_kinesis')
            expect(File).to receive(:read).with('./swagger.json').and_return('{"test": "test"}')

            init
        end

        it "should initialize logger" do
            expect($logger.class).to eq(RSpec::Mocks::Double)
        end
        
        it "should initialize db_fields" do
            expect($db_fields.class).to eq(Hash)
        end
        
        it "should initialize kinesis_client" do
            expect($kinesis_client).to eq('mock_kinesis')
        end
        
        it "should initialize swagger doc" do
            expect($swagger_doc['test']).to eq('test')
        end
    end

    describe :handle_event do
        before do
            allow(self).to receive(:init)
            $logger = double(:info => nil)
            $swagger_doc = 'test'
        end

        it 'should return swagger docs with GET request to /docs/holding' do
            expect(self).to receive(:init)
            expect(HTTPMethods).to receive(:respond).with(200, 'test').and_return('test_swagger_resp')

            res = handle_event(
                event: { 'path' => '/docs/holdings', 'httpMethod' => 'GET' },
                context: {}
            )

            expect(res).to eq('test_swagger_resp')
        end

        it 'should invoke get_holdings_req for other GET requests' do
            expect(self).to receive(:init)
            expect(HTTPMethods).to receive(:get_holdings_req).with({
                'path' => '/holdings',
                'httpMethod' => 'GET'}
            ).and_return('test_holding_rec')

            res = handle_event(
                event: { 'path' => '/holdings', 'httpMethod' => 'GET' },
                context: {}
            )

            expect(res).to eq('test_holding_rec')
        end

        it 'should invoke post_holding for POST requests' do
            expect(self).to receive(:init)
            expect(HTTPMethods).to receive(:post_holding).with({
                'path' => '/holding',
                'httpMethod' => 'POST'}
            ).and_return('test_store_resp')

            res = handle_event(
                event: { 'path' => '/holding', 'httpMethod' => 'POST' },
                context: {}
            )

            expect(res).to eq('test_store_resp')
        end

        it 'should return 500 error if method is invalid' do
            expect(self).to receive(:init)
            expect(HTTPMethods).to receive(:respond).with(500, "Path '' or Method 'put' not allowed").and_return('test_error_resp')

            res = handle_event(
                event: { 'path' => '', 'httpMethod' => 'PUT' },
                context: {}
            )

            expect(res).to eq('test_error_resp')
        end
    end
end