class PhotoService
  def self.similar(user, tag)
    if tag.present?
      client = Instagram.setup_client("some_key", "some_secret")
      tagged_photos = client.photos_tagged(tag)

      tagged_photos.select do |photo|
        # Do a lot things here:
        # Check bio, location, posts,
        # hashtags, etc.
      end
    else
      []
    end
  end
end