class CreateSurrenders < ActiveRecord::Migration
  def change
    create_table :surrenders do |t|
      t.integer :entry_id
      t.string :shop
      t.string :address1
      t.string :address2
      t.string :retriever
      t.integer :items_count
      t.timestamps
    end
    add_index :surrenders, :entry_id
  end
end