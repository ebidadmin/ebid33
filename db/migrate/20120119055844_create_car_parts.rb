class CreateCarParts < ActiveRecord::Migration
  def change
    create_table :car_parts do |t|
      t.string :name
      t.string :creator_id
      t.timestamps
    end
  end
end
