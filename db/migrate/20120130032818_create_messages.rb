class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :user_id
      t.string :user_type
      t.integer :alias
      t.integer :user_company_id
      t.integer :reciever_id
      t.integer :reciever_company_id
      t.integer :entry_id
      t.integer :order_id
      t.text :message
      t.boolean :open_tag,    default: false
      t.string :ancestry
      t.timestamps
    end
    add_index :messages, :user_id
    add_index :messages, :user_company_id
    add_index :messages, :reciever_id
    add_index :messages, :reciever_company_id
    add_index :messages, :entry_id
    add_index :messages, :order_id
    add_index :messages, :ancestry
  end

  def self.down
    drop_table :messages
  end
end
