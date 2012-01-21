class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :user
      t.references :company
      t.string :ref_no
      t.integer :year_model,           limit: 4 
      t.references :car_brand,     default: 0
      t.references :car_model,     default: 0
      t.references :car_variant,   default: 0
      t.string :plate_no
      t.string :serial_no
      t.string :motor_no
      t.date :date_of_loss
      t.references :city
      t.references :term
      t.integer :line_items_count,    default: 0
      t.integer :photos_count,        default: 0
      t.timestamps
      t.string :status,               default: 'New'
      t.datetime :online
      t.date :bid_until
      t.integer :bids_count,          default: 0
      t.datetime :decided
      t.datetime :relisted
      t.integer :relist_count,        default: 0
      t.date :expired
      t.boolean :chargeable_expiry,   default: false
      t.integer :oders_count,         default: 0
    end
    add_index :entries, :user_id
    add_index :entries, :company_id
    add_index :entries, :car_brand_id
    add_index :entries, :car_model_id
    add_index :entries, :car_variant_id
    add_index :entries, :city_id
    add_index :entries, :term_id
  end
end
