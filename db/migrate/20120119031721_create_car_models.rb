class CreateCarModels < ActiveRecord::Migration
  def change
    create_table :car_models do |t|
      t.references :car_brand
      t.string :name
      t.integer :creator_id
      t.timestamps
    end
    add_index :car_models, :car_brand_id
    add_index :car_models, :creator_id
  end
end
