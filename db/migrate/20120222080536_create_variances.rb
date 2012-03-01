class CreateVariances < ActiveRecord::Migration
  def change
    create_table :variances do |t|
      t.integer :user_id
      t.integer :company_id
      t.integer :entry_id
      t.integer :line_item_id
      t.integer :qty,             null: false, default: 1
      t.decimal :var_base,        precision: 10, scale: 2
      t.decimal :discount,        precision: 4, scale: 2
      t.decimal :var_amt,         precision: 10, scale: 2
      t.decimal :var_total,       precision: 10, scale: 2
      t.string :var_type
      t.integer :var_company
      t.integer :bid_id
      t.decimal :amount,          precision: 10, scale: 2
      t.decimal :total,           precision: 10, scale: 2
      t.string :bid_type
      t.integer :seller_company_id
      t.decimal :variance,        precision: 10, scale: 2
      t.timestamps
    end
    add_index :variances, :user_id
    add_index :variances, :company_id
    add_index :variances, :seller_company_id
    add_index :variances, :entry_id
    add_index :variances, :line_item_id
    add_index :variances, :bid_id
  end
end