class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.integer :cart_id
      t.integer :car_part_id
      t.integer :quantity
      t.string :specs

      t.timestamps
    end
    add_index :cart_items, :cart_id
    add_index :cart_items, :car_part_id
  end
end
