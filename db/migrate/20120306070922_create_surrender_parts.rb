class CreateSurrenderParts < ActiveRecord::Migration
  def change
    create_table :surrender_parts do |t|
      t.integer :surrender_id
      t.integer :line_item_id
      t.integer :car_part_id
    end
    add_index :surrender_parts, :surrender_id
    add_index :surrender_parts, :line_item_id
    add_index :surrender_parts, :car_part_id
  end
end