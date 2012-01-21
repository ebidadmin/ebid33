class Entry < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :ref_no, :year_model, :car_brand_id, :car_model_id, :car_variant_id, :plate_no, :serial_no, :motor_no, :date_of_loss, :city_id, :term_id, :line_items_count, :photos_count, :status, :online, :bid_until, :bids_count, :decided, :relisted, :relist_count, :expired, :chargeable_expiry, :oders_count
end
