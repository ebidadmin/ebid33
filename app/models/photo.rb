class Photo < ActiveRecord::Base
  belongs_to :entry, :counter_cache => true
  
  has_attached_file :photo,
    :styles => {
      :tiny => ["80x60#", :jpg],
      :large => ["640x480>", :jpg]
    }
end
