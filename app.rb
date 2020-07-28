require 'parallel'
require 'pg'

require_relative 'holding-schema'

def init
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: ENV['DATABASE'],
    host: ENV['DB_HOST'],
    username: ENV['DB_USERNAME'],
    password: ENV['DB_PASSWORD']
  )
  init_db if ENV['INIT_DB']
end

def handle_event(event:, context:)
  init
  p 'handling event: ', event

  records_to_process = []

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
