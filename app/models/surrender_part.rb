class SurrenderPart < ActiveRecord::Base
  belongs_to :surrender
  belongs_to :line_item
  belongs_to :car_part
  
  delegate :name, to: :car_part
  
  
end
