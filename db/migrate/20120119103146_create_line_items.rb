class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :entry
      t.references :car_part
      t.string :specs,        default: ''
      t.integer :quantity,    default: 1
      t.timestamps
      t.string :status,       default: 'New'
      t.integer :bids_count,  default: 0
      t.datetime :relisted
      t.integer :order_id
    end
    add_index :line_items, :entry_id
    add_index :line_items, :car_part_id
  end
end
