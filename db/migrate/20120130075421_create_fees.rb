class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.integer :buyer_company_id
      t.integer :buyer_id
      t.integer :seller_company_id
      t.integer :seller_id
      t.integer :entry_id
      t.integer :line_item_id
      t.integer :order_id
      t.integer :bid_id
      t.decimal :bid_total,     precision: 10, scale: 2, null: false, default: 0.0
      t.string :bid_type
      t.integer :bid_speed
      t.decimal :perf_ratio,    precision: 5, scale: 2
      t.decimal :fee_rate,      precision: 5, scale: 3
      t.decimal :fee,           precision: 10, scale: 2, null: false, default: 0.0
      t.string :fee_type
      t.date :order_paid
      t.date :created_at
      t.date :billed
      t.date :paid
      t.decimal :split_amount,  precision: 10, scale: 2, null: false, default: 0.0
      t.date :split_remitted
    end
    add_index :fees, :buyer_company_id
    add_index :fees, :seller_company_id
    add_index :fees, :buyer_id
    add_index :fees, :seller_id
    add_index :fees, :entry_id
    add_index :fees, :line_item_id
    add_index :fees, :order_id
    add_index :fees, :bid_id
  end
end
