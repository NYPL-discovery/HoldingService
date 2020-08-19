require 'parallel'
require 'pg'
require 'nypl_ruby_util'
require_relative 'models/record'

require_relative 'holding-schema'

def init
  $logger = NYPLRubyUtil::NyplLogFormatter.new(STDOUT, level: ENV['LOG_LEVEL'])
  $logger.info 'env: ', ENV.sort
  kms_client =  NYPLRubyUtil::KmsClient.new(ENV['KMS_OPTIONS'] ? JSON.parse(ENV['KMS_OPTIONS']) : {})
  password = kms_client.decrypt(ENV['DB_PASSWORD'])
  $logger.info 'authenticating with password: ', { message: password }
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

  if method == 'get' && path == "/docs/holdings"
    return respond 200, $swagger_doc
  end

  if method == 'get'
    return get_holding(event)
  end


  begin
    body = JSON.parse(event["body"])
    records = body.map {|record| db_record(record)}
  rescue => e
    $logger.error('problem parsing JSON for event', { message: e.message })
    return respond 500, { message: e.message }
  end

  $logger.info('successfully parsed records')

  begin
    Record.upsert_all(records, unique_by: :id)
  rescue => e
    $logger.error('problem persisting records to database', { message: e.message })
    return respond 500, { message: e.message }
  end

  $logger.info('successfully persisted records')

  begin
    body.each {|record| $kinesis_client << record }
  rescue => e
    return respond 500, { message: e.message }
  end


  respond 200
end

def get_holding(event)
  $logger.info('handling get request')
  params = event['queryStringParameters']
  $logger.info('params: ', params)
  if ids = params['id']
    $logger.info("getting by ids: #{ids}")
    begin
      parsed_ids = ids.split(",").map {|id| id.to_i}
      records = Record.find(parsed_ids)
      return respond(200, records.map {|record| record.to_json})
    rescue => e
      $logger.error("problem getting records with ids: #{ids}", e.message)
      return respond(500, "problem getting records with ids: #{ids}, message: #{e.message}")
    end
  elsif bib_ids = params['bib_ids']
    offset = params['offset'] ? params['offset'].to_i : 0
    limit = params['limit'] ? params['limit'].to_i : 20
    $logger.info("getting by bib_ids: #{bib_ids}, offset: #{offset}, limit: #{limit}")
    begin
      parsed_bib_ids = bib_ids.split(",").map {|id| id.to_i}
      records = Record.where("bib_ids && ARRAY[?]::int[]", parsed_bib_ids).offset(offset).limit(limit)
      return respond(200, records.map {|record| record.to_json})
    rescue => e
      $logger.error("problem getting records with bib_ids: #{bib_ids}, offset: #{offset}, limit: #{limit}", e.message)
      return respond(500, "problem getting records with bib_ids: #{bib_ids}, offset: #{offset}, limit: #{limit} message: #{e.message}")
    end
  else
    $logger.info("Missing required fields ids or bib_ids")
    return respond(400, "Missing required fields ids or bib_ids")
  end
end

def db_record(record)
  record.map {|k,v| [$db_fields[k], v]}.to_h
end

def respond(statusCode = 200, body = nil)
  $logger.info("Responding with #{statusCode}", { message: body })

  {
    statusCode: statusCode,
    body: body.to_json,
    headers: {
      "Content-type": "application/json"
    }
  }
end
