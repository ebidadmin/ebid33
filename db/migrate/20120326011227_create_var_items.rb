class CreateVarItems < ActiveRecord::Migration
  def change
    create_table :var_items do |t|
      t.integer :variance_id
      t.integer :line_item_id
      t.integer :qty,             null: false, default: 1
      t.decimal :var_base,        precision: 10, scale: 2
      t.decimal :discount,        precision: 4, scale: 2
      t.decimal :var_amt,         precision: 10, scale: 2
      t.decimal :var_total,       precision: 10, scale: 2
      t.string :var_type
      t.integer :bid_id
      t.decimal :amount,          precision: 10, scale: 2
      t.decimal :total,           precision: 10, scale: 2
      t.string :bid_type
      t.integer :seller_company_id
      t.decimal :var_net,        precision: 10, scale: 2
      t.timestamps
    end
    add_index :var_items, :variance_id
    add_index :var_items, :line_item_id
    add_index :var_items, :bid_id
    add_index :var_items, :seller_company_id
  end
end
