# [fit] *John Mosesman*
##  [fit] Developer at LifeChurch.tv

---

# [fit] *How I Leveled*
## [fit] Up My Code

---

# [fit] Scenario
## Instagram photos similar to my interests.

---

# [fit] *Scale of 1 to DHH*
# [fit] how well do you know Rails?

---

# [fit] `rails new me`

---

# [fit] Level 1
## [fit] Minimal / No Structure

---

```ruby
# app/controllers/photos_controller.rb
class PhotosController < ApplicationController
  def index
    @photos =
      if params[:tag].present?
        client = Instagram.setup_client("some_key", "some_secret")
        tagged_photos = client.photos_tagged(params[:tag])

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
```

---

# [fit] Not great
# [fit] but hey, it works.

---

# [fit] Level 2
# Fat Models, Skinny Controllers
## (Done Poorly)

---

# [fit] I used the word user
## [fit] so it must belong in the user model?

---

```ruby
# app/models/user.rb
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
end
```

---

```ruby
# app/models/user.rb
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
```

---

```ruby
# app/controllers/photos_controller.rb
class PhotosController < ApplicationController
  def index
    @photos =
      if params[:tag].present?
        client = Instagram.setup_client("some_key", "some_secret")
        tagged_photos = client.photos_tagged(params[:tag])

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
```

---

```ruby
# app/controllers/photos_controller.rb
class PhotosController < ApplicationController
  before_filter :authenticate_user!

  def index
    @photos = current_user.similar_photos(params[:tag])
  end
end
```

---


```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  ...
  
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
```

---

# [fit] Level 3
## [fit] Single Responsibility Principle

---

## [fit] To paraphase Wikipedia: 
## [fit] "Each class should only do one thing."

---

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  ...
  
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
```

---

# [fit] `class User < ActiveRecord::Base`

---

# [fit] `ActiveRecord::Base`

---

# Enter: 
# [fit] Service Objects

---

```ruby
# app/services/photo_service.rb
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
```

---

```ruby
class PhotosController < ApplicationController
  before_filter :authenticate_user!

  def index
    @photos = PhotoService.similar(current_user, params[:tag])
  end
end
```

---

# [fit] Level 4??

---

# [fit] @johnmosesman

