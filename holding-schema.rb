require 'active_record'

def init_db
  ActiveRecord::Schema.define do
    create_table :records do |t|
      t.index :id, unique: true
      t.integer :bibIds, array: true, default: []
      t.string :bibIdLinks, array: true, default: []
      t.integer :itemIds, array: true, default: []
      t.string :itemIdLinks, array: true, default: []
      t.boolean :inheritLocation
      t.string :allocationRule
      t.integer :accountingUnit
      t.string :labelCode
      t.string :serialCode1
      t.string :serialCode2
      t.string :serialCode3
      t.string :serialCode4
      t.string :claimOnDate
      t.string :receivingLocationCode
      t.string :vendorCode
      t.string :updateCount
      t.integer :pieceCount
      t.string :eCheckInCode
      t.string :mediaTypeCode
      t.date :updatedDate
      t.date :createdDate
      t.date :deletedDate
      t.boolean :deleted
      t.boolean :suppressed
      t.jsonb :fixedFields, default: {}
      t.jsonb :varFields, default: {}
      t.jsonb :holdings, default: {}
      t.jsonb :location, default: {}
      t.jsonb :checkInCards, default: {}
    end
  end
end
