require 'parallel'
require 'pg'
require 'nypl_ruby_util'
require_relative 'models/record'

require_relative 'holding-schema'

def init
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: ENV['DATABASE'],
    host: ENV['DB_HOST'],
    username: ENV['DB_USERNAME'],
    password: ENV['DB_PASSWORD']
  )
  $logger = NYPLRubyUtil::NyplLogFormatter.new(STDOUT, level: ENV['LOG_LEVEL'])
  $db_fields = Hash.new { |h,k| h[k] = k.gsub(/([a-z])([^a-z])/){"#{$1}_#{$2.downcase}"}  }
  $kinesis_client = NYPLRubyUtil::KinesisClient.new(
    schema_string: ENV['SCHEMA_STRING'],
    stream_name: ENV['STREAM_NAME']
  )
end

def handle_event(event:, context:)
  init

  $logger.info('handling event ', event)

  begin
    records = event["body"].map({|record_string| JSON.parse(record_string)})
  rescue => e
    $logger.error('problem parsing JSON for event', e.message)
    raise e
  end

  begin
    Record.upsert_all(records, unique_by: :id)
  rescue => e
    $logger.error('problem persisting records to database', e.message)
    raise e
  end

  records.each {|record| $kinesis_client << record }

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
