class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.references :user
      t.references :entry
      t.references :line_item
      t.references :car_brand
      t.decimal :amount,          precision: 10, scale: 2
      t.integer :quantity,        null: false, default: 1
      t.decimal :total,           precision: 10, scale: 2
      t.string :bid_type
      t.integer :bid_speed
      t.boolean :lot,             default: false
      t.string :status,           null: false, default: 'New'
      t.timestamps
      t.date :ordered
      t.references :order
      t.date :delivered
      t.date :paid
      t.date :cancelled
      t.date :declined
      t.date :expired
    end
    add_index :bids, :user_id
    add_index :bids, :entry_id
    add_index :bids, :line_item_id
    add_index :bids, :order_id
  end
end
