class User < ActiveRecord::Base
  before_save :do_something
  before_validation :another_thing

  devise :database_somethingable, :anotherthingable,
         :differentable, :elsable, :ableable

  has_many :something_elses
  has_many :somethings, through: :something_elses

  scope :some_scope, -> { where(scope: true) }

  def self.some_class_thing
    # ...
  end

  def something
    # ...
  end

  def something_else
    # ...
  end

  def something_different
    # ...
  end

  def similar_photos(tag)
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