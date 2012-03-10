class Photo < ActiveRecord::Base
  belongs_to :entry, counter_cache: true
  
  has_attached_file :photo, styles: { tiny: ["80x60#", :jpg], thumb: ["222x142#", :jpg], large: ["640x480>", :jpg] }
      # default_url: '/assets/image_placeholder.png', 
      # styles: { tiny: ["80x60#", :jpg], thumb: ["222x142#", :jpg], large: ["640x480>", :jpg] },
      # url: "/system/:class/:id/:style/:filename",
      # path: ":rails_root/public/system/:class/:id/:style/:filename"
    
  validates_attachment_presence :photo, message: "You must upload at least 2 photos."
  validates_attachment_content_type :photo, 
  :content_type => ['image/jpeg', 'image/pjpeg', 
                                   'image/jpg', 'image/png'], message: "Acceptable photo formats are jpg, jpeg, or png."

  process_in_background :photo
end
