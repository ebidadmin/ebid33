class CreateTempCompanies < ActiveRecord::Migration
  def change
    create_table :temp_companies do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :zip_code
      t.integer :city_id
      t.string :approver
      t.string :approver_position
      t.timestamps
      t.integer :primary_role
      t.date :trial_start
      t.date :trial_end
      t.date :metering_date
      t.decimal :perf_ratio,    precision: 5, scale: 2
    end
  end
end
