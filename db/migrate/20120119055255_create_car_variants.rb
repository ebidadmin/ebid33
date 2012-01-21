class CreateCarVariants < ActiveRecord::Migration
  def change
    create_table :car_variants do |t|
      t.references :car_brand
      t.references :car_model
      t.string :name
      t.string :start_year
      t.string :end_year
      t.integer :creator_id
      t.timestamps
    end
    add_index :car_variants, :car_brand_id
    add_index :car_variants, :car_model_id
    add_index :car_variants, :creator_id
  end
end
