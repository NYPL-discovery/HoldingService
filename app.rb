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
end

def handle_event(event:, context:)
  logger = NYPLRubyUtil::NyplLogFormatter.new(STDOUT, level: ENV['LOG_LEVEL'])
  logger.info('handling event ', event)
  p 'handling event: ', event, ENV.sort
  init

  records_to_process = []
  kinesis_client = NYPLRubyUtil::KinesisClient.new(
    schema_string: ENV['SCHEMA_STRING'],
    stream_name: ENV['STREAM_NAME']
  )

  event["body"].each do |record|
    Record.create record
    kinesis_client << record
  end

  # Parse records into array for parallel processing
  # event["Records"]
  #   .select { |record| record["eventSource"] == "aws:kinesis" }
  #   .each do |record|
  #     records_to_process << record
  #   end

  # Process records in parallel
  # record_results = Parallel.map(records_to_process, in_processes: 3) { |record| process_record(record) }
end

def process_record record
  decoded_record = parse_record(record)
  unless decoded_record && should_process?(decoded_record)
    return decoded_record ? [decoded_record['id'], 'SKIPPING'] : [nil, 'ERROR']
  end

  return store_record(decoded_record)
end

def parse_record(record)
  record
end

def should_process?(data)
  true
end

def store_record(decoded_record)
  decoded_record
end
