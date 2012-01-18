class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :username,       limit: 20, null: false
      t.database_authenticatable null: false
      t.encryptable
      t.string :remember_token
      t.rememberable
      t.trackable
      t.recoverable
      t.lockable lock_strategy: :failed_attempts, unlock_strategy: :both
      # t.confirmable
      # t.token_authenticatable

      t.timestamps
      t.boolean :enabled,       default: true, null: false                      
      t.integer :entries_count, default: 0, null: false                                      
      t.integer :bids_count,    default: 0, null: false         
      t.datetime :tos_agreed
      t.boolean :opt_in,        default: true, null: false                      
    end

    add_index :users, :username
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :unlock_token,         unique: true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

end
