class CreateVariances < ActiveRecord::Migration
  def change
    create_table :variances do |t|
      t.integer :user_id
      t.integer :company_id
      t.integer :entry_id
      t.integer :var_company_id
      t.timestamps
    end
    add_index :variances, :user_id
    add_index :variances, :company_id
    add_index :variances, :entry_id
    add_index :variances, :var_company_id
  end
end