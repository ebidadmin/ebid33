class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :user
    end
  end
end
