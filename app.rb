require 'parallel'
require 'pg'
require 'nypl_ruby_util'
require_relative 'models/record'

require_relative 'holding-schema'

def init
  $logger = NYPLRubyUtil::NyplLogFormatter.new(STDOUT, level: ENV['LOG_LEVEL'])
  kms_client =  NYPLRubyUtil::KmsClient.new(ENV['KMS_OPTIONS'] ? JSON.parse(ENV['KMS_OPTIONS']) : {})
  password = kms_client.decrypt(ENV['DB_PASSWORD'])
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: ENV['DATABASE'],
    host: ENV['DB_HOST'],
    username: ENV['DB_USERNAME'],
    password: password
  )
  $db_fields = Hash.new { |h,k| h[k] = k.gsub(/([a-z])([^a-z])/){"#{$1}_#{$2.downcase}"}  }
  $kinesis_client = NYPLRubyUtil::KinesisClient.new(
    schema_string: ENV['SCHEMA_STRING'],
    stream_name: ENV['STREAM_NAME']
  )
  $swagger_doc = JSON.load(File.read('./swagger.json'))
end

def handle_event(event:, context:)
  init
  path = event["path"]
  method = event["httpMethod"].downcase

  $logger.info('handling event ', event)

  if method == 'get' && path == "/docs/holding"
    return respond 200, $swagger_doc
  end

  begin
    records = JSON.parse(event["body"]).map {|record| db_record(record)}
  rescue => e
    $logger.error('problem parsing JSON for event', e.message)
    return respond 500, { message: e.message }
  end

  begin
    Record.upsert_all(records, unique_by: :id)
  rescue => e
    $logger.error('problem persisting records to database', e.message)
    return respond 500, { message: e.message }
  end

  begin
    records.each {|record| $kinesis_client << record }
  rescue => e
    return respond 500, { message: e.message }
  end


  respond 200
end

def db_record(record)
  record.map {|k,v| [$db_fields[k], v]}.to_h
end

def respond(statusCode = 200, body = nil)
  $logger.debug("Responding with #{statusCode}", body)

  {
    statusCode: statusCode,
    body: body.to_json,
    headers: {
      "Content-type": "application/json"
    }
  }
end
