require 'nypl_ruby_util'
require_relative '../models/record'


class HTTPMethods

  def self.get_holding(event)
    $logger.info('handling get request')
    params = event['queryStringParameters']
    $logger.info("params: #{params}")
    errors = check_for_param_errors(params)
    return errors if errors
    if params['ids']
      ids, getting_by, identifier_for_where = [params['ids'], 'ids', 'ARRAY[id]::int[]']
    end
    if params['bib_id']
      ids, getting_by, identifier_for_where = [params['bib_id'], 'bib_id', 'bib_ids']
    end
    $logger.info("getting by #{getting_by}: #{ids}")
    begin
      parsed_ids = ids.split(",").map {|id| id.to_i}
      records = Record.where("#{identifier_for_where} && ARRAY[?]::int[]", parsed_ids)
      $logger.info("responding 200")
      return respond(200, records.map {|record| record.to_json})
    rescue => e
      message = "problem getting records with #{getting_by}: #{ids}, message: #{e.message}"
      $logger.error(message)
      return respond(500, message)
    end
  end

  def self.check_for_param_errors(params)
    error_messages = []
    if !params
      error_messages << "Must have bib_id or ids"
    elsif params['ids'] && params['bib_id']
      error_messages << "Can only have one of ids, bib_id"
    elsif params['bib_id'] && !params['bib_id'].match(/^\d+$/)
      error_messages << "bib_id must be a single numerical value"
    end
    if !error_messages.empty?
      return respond(400, error_messages.join(", "))
    end
  end

  def self.post_holding(event)
    $logger.info("handling post request")

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

    respond 200, { "message": "Stored #{body.length} records Successfully", "errors": []}
  end



  def self.db_record(record)
    record.map {|k,v| [$db_fields[k], v]}.to_h
  end


  def self.respond(statusCode = 200, body = nil)
    $logger.info("Responding with #{statusCode}", { message: body })

    {
      statusCode: statusCode,
      body: body.to_json,
      headers: {
        "Content-type": "application/json"
      }
    }
  end

end
