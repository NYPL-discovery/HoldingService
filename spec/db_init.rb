require 'pg'
require 'active_record'
require_relative '../models/record'
require_relative '../holding-schema'

def create_test_db
  ActiveRecord::Schema.define do
    drop_table :records, if_exists: true
  end

  init_db

  record_1 = {
    "id"=>1,
    "bibIds"=>[1, 2, 3],
    "bibIdLinks"=>[],
    "itemIds"=>[],
    "itemIdLinks"=>[],
    "inheritLocation"=>nil,
    "allocationRule"=>nil,
    "accountingUnit"=>1,
    "labelCode"=>"blah",
    "serialCode1"=>nil,
    "serialCode2"=>nil,
    "serialCode3"=>nil,
    "serialCode4"=>nil,
    "claimOnDate"=>nil,
    "receivingLocationCode"=>nil,
    "vendorCode"=>nil,
    "updateCount"=>nil,
    "pieceCount"=>nil,
    "eCheckInCode"=>nil,
    "mediaTypeCode"=>nil,
    "updatedDate"=>nil,
    "createdDate"=>"2020-07-29",
    "deletedDate"=>nil,
    "deleted"=>nil,
    "suppressed"=>nil,
    "fixedFields"=>{},
    "varFields"=>{},
    "holdings"=>{"a"=>1, "b"=>[2, 3]},
    "location"=>nil
  }

  record_2 = {
    "id"=>2,
    "bibIds"=>[3,4,5],
    "bibIdLinks"=>[],
    "itemIds"=>[],
    "itemIdLinks"=>[],
    "inheritLocation"=>nil,
    "allocationRule"=>nil,
    "accountingUnit"=>1,
    "labelCode"=>"blah",
    "serialCode1"=>nil,
    "serialCode2"=>nil,
    "serialCode3"=>nil,
    "serialCode4"=>nil,
    "claimOnDate"=>nil,
    "receivingLocationCode"=>nil,
    "vendorCode"=>nil,
    "updateCount"=>nil,
    "pieceCount"=>nil,
    "eCheckInCode"=>nil,
    "mediaTypeCode"=>nil,
    "updatedDate"=>nil,
    "createdDate"=>"2020-07-29",
    "deletedDate"=>nil,
    "deleted"=>nil,
    "suppressed"=>nil,
    "fixedFields"=>{},
    "varFields"=>{},
    "holdings"=>{"a"=>1, "b"=>[2, 3]},
    "location"=>nil
  }

  Record.create record_1
  Record.create record_2
end
