module PhotosHelper
  def photo_url(photo)
    if photo.blob.service.name.to_s == "cloudinary"
      cl_image_path(photo.key)
    else
      url_for(photo)
    end
  end
end
