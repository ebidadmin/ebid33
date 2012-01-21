class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :nickname
      t.integer :primary_role
      t.date :trial_start
      t.date :trial_end
      t.date :metering_date
      t.decimal :perf_ratio,    precision: 5, scale: 2
      t.timestamps
    end
  end
end
