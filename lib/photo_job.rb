class PhotoJob < Struct.new(:photo_id)
  def perform
    Photo.find(self.photo_id).regenerate_styles!
  end
end