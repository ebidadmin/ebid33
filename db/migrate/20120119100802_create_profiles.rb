class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user
      t.references :company
      t.references :branch
      t.string :first_name
      t.string :last_name
      t.references :rank
      t.string :phone
      t.string :fax
      t.date :birthdate
      t.timestamps
    end
    add_index :profiles, :user_id
    add_index :profiles, :company_id
    add_index :profiles, :branch_id
  end
end
