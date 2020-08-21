require 'parallel'
require 'pg'
require 'nypl_ruby_util'
require_relative 'models/record'
require_relative 'src/http_methods'

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
    return HTTPMethods.respond 200, $swagger_doc
  end

  if method == 'get'
    return HTTPMethods.get_holding(event)
  end

  if method == 'post'
    return HTTPMethods.post_holding(event)
  end

end
