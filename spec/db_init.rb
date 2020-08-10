require 'pg'
require 'active_record'

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
    end
  end
end
