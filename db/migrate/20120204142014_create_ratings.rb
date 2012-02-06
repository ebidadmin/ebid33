class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :order_id
      t.integer :user_id
      t.integer :ratee_id
      t.decimal :stars
      t.text :review
      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
