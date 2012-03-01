class CreateVarCompanies < ActiveRecord::Migration
  def self.up
    create_table :var_companies do |t|
      t.string :name
      t.integer :creator_id
      t.timestamps
    end
  end

  def self.down
    drop_table :var_companies
  end
end
