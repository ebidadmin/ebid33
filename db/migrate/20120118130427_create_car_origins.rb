class CreateCarOrigins < ActiveRecord::Migration
  def change
    create_table :car_origins do |t|
      t.string :name
    end
    CarOrigin.create(name: 'Japanese')
    CarOrigin.create(name: 'American')
    CarOrigin.create(name: 'European')
    CarOrigin.create(name: 'Asian')
  end
end
