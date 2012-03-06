class Surrender < ActiveRecord::Base
  attr_accessible :entry_id, :shop, :address1, :address2, :retriever, :items_count
  
  belongs_to :entry
  has_many :surrender_parts, dependent: :destroy
end
