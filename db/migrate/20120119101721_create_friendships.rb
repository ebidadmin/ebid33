class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships, id: false do |t|
      t.integer :company_id
      t.integer :friend_id
      t.timestamps
    end
    add_index :friendships, :company_id
    add_index :friendships, :friend_id
  end
end
