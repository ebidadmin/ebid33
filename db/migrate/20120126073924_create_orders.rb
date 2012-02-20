class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :company_id
      t.integer :entry_id
      t.string :ref_no,           default: ''
      t.string :ref_name,         default: ''
      t.string :deliver_to,       default: ''
      t.string :address1,         default: ''
      t.string :address2,         default: ''
      t.string :contact_person,   default: ''
      t.string :phone,            default: ''
      t.string :fax,              default: ''
      t.text :instructions,       default: ''
      t.string :status,           null:false, default: 'New PO'
      t.string :buyer_ip,         default: ''
      t.integer :items_count,     null:false, default: 0
      t.decimal :order_total,     precision: 10, scale: 2, null: false, default: 0.0
      t.datetime :created_at
      t.integer :seller_id
      t.integer :seller_company_id
      t.boolean :seller_confirmation, null:false, default: 0
      t.datetime :confirmed
      t.date :delivered
      t.date :due_date
      t.date :paid_temp
      t.date :paid
      t.date :cancelled
      t.integer :ratings_count, null:false, default: 0
    end
    add_index :orders, :user_id
    add_index :orders, :company_id
    add_index :orders, :entry_id
    add_index :orders, :seller_id
    add_index :orders, :seller_company_id
  end
end
