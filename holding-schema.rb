require 'active_record'

def init_db
  ActiveRecord::Schema.define do
    create_table :records do |t|
      t.string :bib_id
      t.string :media_type
      t.string :label_type
      t.string :record_type
      t.string :holding_string
      t.boolean :is_index
      t.boolean :incomplete
      t.boolean :negation
    end
  end
end
