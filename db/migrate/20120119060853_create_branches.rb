class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.references :company
      t.string :name
      t.string :address1
      t.string :address2
      t.integer :zip_code
      t.references :city
      t.integer :approver_id
      t.timestamps
    end
    add_index :branches, :company_id
    add_index :branches, :city_id
    add_index :branches, :approver_id
  end
end
