class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.integer :name
    end
  end
end
