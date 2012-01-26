class Photo < ActiveRecord::Base
  belongs_to :entry, :counter_cache => true
  
  has_attached_file :photo,
    :styles => {
      :tiny => ["80x60#", :jpg],
      :large => ["640x480>", :jpg]
    }

  # cancel post-processing now, and set flag...
  before_photo_post_process do |photo|
    if photo.data_changed?
      photo.processing = true
      false # halts processing
    end
  end

  # ...and perform after save in background
  after_save do |photo| 
    if photo.data_changed?
      Delayed::Job.enqueue PhotoJob.new(photo.id) # add to queue
      # photo.delay.regenerate_styles!
    end
  end

  # generate styles (downloads original first)
  def regenerate_styles!
    self.photo.reprocess! 
    self.processing = false   
    self.save(:validate => false) #save(false)
  end

  # detect if our source file has changed
  def data_changed?
    self.photo_file_size_changed? || 
    self.photo_file_name_changed? ||
    self.photo_content_type_changed? || 
    self.photo_updated_at_changed?
  end
end
