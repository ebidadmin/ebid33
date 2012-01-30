class CreateCartEntries < ActiveRecord::Migration
  def change
    create_table :cart_entries do |t|
      t.integer :cart_id
      t.string :ref_no
      t.integer :year_model
      t.integer :car_brand_id
      t.integer :car_model_id
      t.integer :car_variant_id
      t.string :plate_no
      t.string :serial_no
      t.string :motor_no
      t.date :date_of_loss
      t.integer :city_id
      t.integer :term_id
      t.timestamps
    end
    add_index :cart_entries, :cart_id
    add_index :cart_entries, :car_brand_id
    add_index :cart_entries, :car_model_id
    add_index :cart_entries, :car_variant_id
    add_index :cart_entries, :city_id
    add_index :cart_entries, :term_id
  end
end