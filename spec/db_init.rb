require 'pg'
require 'active_record'
require_relative '../models/record'

def init_db
  ActiveRecord::Schema.define do
    drop_table :records, if_exists: true
  end

  ActiveRecord::Schema.define do
    create_table :records do |t|
      t.index :id, unique: true
      t.integer :bib_ids, array: true, default: []
      t.string :bib_id_links, array: true, default: []
      t.integer :item_ids, array: true, default: []
      t.string :item_id_links, array: true, default: []
      t.boolean :inherit_location
      t.string :allocation_rule
      t.integer :accounting_unit
      t.string :label_code
      t.string :serial_code_1
      t.string :serial_code_2
      t.string :serial_code_3
      t.string :serial_code_4
      t.string :claim_on_date
      t.string :receiving_location_code
      t.string :vendor_code
      t.string :update_count
      t.integer :piece_count
      t.string :e_check_in_code
      t.string :media_type_code
      t.date :updated_date
      t.date :created_date
      t.date :deleted_date
      t.boolean :deleted
      t.boolean :suppressed
      t.jsonb :fixed_fields, default: {}
      t.jsonb :var_fields, default: {}
      t.jsonb :holdings, default: {}
      t.jsonb :location, default: {}
      t.jsonb :check_in_cards, default: {}
    end
  end

  record_1 = {
    "id"=>1,
    "bib_ids"=>[1, 2, 3],
    "bib_id_links"=>[],
    "item_ids"=>[],
    "item_id_links"=>[],
    "inherit_location"=>nil,
    "allocation_rule"=>nil,
    "accounting_unit"=>1,
    "label_code"=>"blah",
    "serial_code_1"=>nil,
    "serial_code_2"=>nil,
    "serial_code_3"=>nil,
    "serial_code_4"=>nil,
    "claim_on_date"=>nil,
    "receiving_location_code"=>nil,
    "vendor_code"=>nil,
    "update_count"=>nil,
    "piece_count"=>nil,
    "e_check_in_code"=>nil,
    "media_type_code"=>nil,
    "updated_date"=>nil,
    "created_date"=>"2020-07-29",
    "deleted_date"=>nil,
    "deleted"=>nil,
    "suppressed"=>nil,
    "fixed_fields"=>{},
    "var_fields"=>{},
    "holdings"=>{"a"=>1, "b"=>[2, 3]},
    "location"=>nil
  }

  record_2 = {
    "id"=>2,
    "bib_ids"=>[3,4,5],
    "bib_id_links"=>[],
    "item_ids"=>[],
    "item_id_links"=>[],
    "inherit_location"=>nil,
    "allocation_rule"=>nil,
    "accounting_unit"=>1,
    "label_code"=>"blah",
    "serial_code_1"=>nil,
    "serial_code_2"=>nil,
    "serial_code_3"=>nil,
    "serial_code_4"=>nil,
    "claim_on_date"=>nil,
    "receiving_location_code"=>nil,
    "vendor_code"=>nil,
    "update_count"=>nil,
    "piece_count"=>nil,
    "e_check_in_code"=>nil,
    "media_type_code"=>nil,
    "updated_date"=>nil,
    "created_date"=>"2020-07-29",
    "deleted_date"=>nil,
    "deleted"=>nil,
    "suppressed"=>nil,
    "fixed_fields"=>{},
    "var_fields"=>{},
    "holdings"=>{"a"=>1, "b"=>[2, 3]},
    "location"=>nil
  }

  Record.create record_1
  Record.create record_2
end
