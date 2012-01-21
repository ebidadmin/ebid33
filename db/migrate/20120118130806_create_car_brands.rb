class CreateCarBrands < ActiveRecord::Migration
  def change
    create_table :car_brands do |t|
      t.references :car_origin
      t.string :name
      t.timestamps
    end
    add_index :car_brands, :car_origin_id
  end
end
