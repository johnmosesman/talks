class PhotosController < ApplicationController
  def index
    @photos =
      if params[:search_tag].present?
        client = Instagram.setup_client("some_key", "some_secret")
        tagged_photos = client.photos_tagged(params[:search_tag])

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


class PhotosController < ApplicationController
  before_filter :authenticate_user!

  def index
    @photos = PhotoService.similar(current_user, params[:tag])
  end
end


2048