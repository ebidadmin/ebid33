class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
    end
    
    create_table :roles_users, id: false do |t|
      t.references :user, :role
    end
  end
end
