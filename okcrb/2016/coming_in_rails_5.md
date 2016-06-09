# Housekeeping

## 5.0.0.RC1 - Estimated March 1 and final on March 16

## Ruby 2.2.1+

## One Rails command to rule them all
`bin/rake db:migrate` => `bin/rails db:migrate`

## API Mode

* `rails new backend --api`
* Uses `#to_json` on model (but can still use AMS, JSONAPI, etc.)

# ActiveRecord

## belongs_to has required validation


## Bi-directional destroy dependency

```
class User < ActiveRecord::Base
  has_one :profile, dependent: :destroy
end

class Profile < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
end
```

## LEFT OUTER JOIN
`Author.left_outer_joins(:posts)`

## `or` query

```
class Issue < ActiveRecord::Base
  scope :reported, -> { where(status: 'reported') }
  scope :open,     -> { where(status: 'open') }
end

active_issues = Issue.reported.or(Issue.open)
```

## ActiveRecord’s attribute API

### type casting

```
# db/schema.rb
create_table :store_listings do |t|
  t.decimal :price_in_cents
end

store_listing = StoreListing.new(price_in_cents: '10.1')

store_listing.price_in_cents # => BigDecimal.new(10.1)

===

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer
end

store_listing.price_in_cents # => 10 (yay)
```

### new default

```
# db/schema.rb
create_table :store_listings |t|
  t.string :my_string, default: "original default"
end

# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
  attribute :my_string, :string, default: "new default"
end
```

## suppress

```
class Product < ApplicationRecord
  def launch_without_notifications
    Notification.suppress do
      launch!
    end
  end
end

> product.launch_without_notifications
>
> Notification.count
=> 0
```

## `has_secure_token`

`$ rails g model invite invitation_code:token`

```
class Invite < ActiveRecord::Base
   has_secure_token :invitation_code
end

invite = Invite.new
invite.save
invite.invitation_code # => 44539a6a59835a4ee9d7b112
invite.regenerate_invitation_code # => true
```

## ApplicationRecord

```
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

```
class ApplicationRecord < ActiveRecord::Base
  include MyAwesomeFeature

  self.abstract_class = true
end
```

# Other

## `before_filter` => `before_action` (and all other `*_filter`)

## AR::Relation#count => Enumerable#count
https://github.com/rails/rails/pull/24203

```
# deliveries.select { |delivery| delivery.in_progress? }.size
deliveries.count { |delivery| delivery.in_progress? }
```

## assign_attributes

`ActiveRecord => ActiveModel`

```
class User
  include ActiveModel::AttributeAssignment
  attr_accessor :email, :first_name, :last_name
end

user = User.new
user.assign_attributes({email:      'sam@example.com',
                        first_name: 'Sam',
                        last_name:  'Smith'})
> user.email
#=> "sam@example.com"
> user.first_name
#=> "Sam"
```

## params

```
class PostsController < ApplicationController
  def create
    ...
  end

  private
    def post_params
      params.require(:post).permit(:title, :body)
    end
end
```

* `ActionController::Parameters` returns an _object_ not a _hash_
* `delegate :keys, :key?, :has_key?, :empty?, :inspect, to: :@parameters`

```
def post_params
  params.require(:post).permit(:title, :body).to_h  `# <-- note `.to_h`
end
```

```
# actionpack/lib/action_controller/metal/strong_parameters.rb
def to_h
  if permitted?
    @parameters.to_h
  else
    slice(*self.class.always_permitted_parameters).permit!.to_h
  end
end
```

* `to_unsafe_h`
* ` config.always_permitted_parameters = %w( controller action param_1 param_2 )`


# Quality of Life

## Large query warning

```
>> Post.published.count
=> 25000

>> Post.where(published: true).each do |post|
     post.archive!
   end

# Loads 25000 posts in memory
```

```
config.active_record.warn_on_records_fetched_greater_than = 1500

>> Post.where(published: true).each do |post|
     post.archive!
   end

=> Query fetched 25000 Post records: SELECT "posts".* FROM "posts" WHERE "posts"."published" = ? [["published", true]]
   [#<Post id: 1, title: 'Rails', user_id: 1, created_at: "2016-02-11 11:32:32", updated_at: "2016-02-11 11:32:32", published: true>, #<Post id: 2, title: 'Ruby', user_id: 2, created_at: "2016-02-11 11:36:05", updated_at: "2016-02-11 11:36:05", published: true>,....]

```

(Use `find_each`)

## Faster dev mode

Watches for events on file system vs tree walk

```
group :development do
  gem 'listen', '~> 3.0.4'
end
```

# Testing

## `ActionController::TestCase` => `ActionDispatch::IntegrationTest`

Will be moved into own gem in Rails 5.1

### `assigns` and `assert_template` deprecated

`rails-controller-testing`: Restores the ability to use `assigns` and `assert_template`

## Use URL instead of action name

```
class ProductsControllerTest < ActionDispatch::IntegrationTest
  def test_index_response
    # get :index
    get products_url
    assert_response :success
  end
end
```

## New test runners

```
$ bin/rails test test/models/user_test.rb:27    # (Doesn't have to be first line)
$ bin/rails test test/models/user_test.rb:27 test/models/post_test.rb:42
$ bin/rails test test/controllers test/integration
```

## Better failure messages

```
$ bin/rails t
Run options: --seed 51858

# Running:

.F

Failure:
PostsControllerTest#test_should_get_new:
Expected response to be a <success>, but was a <302> redirect to <http://test.host/posts>

bin/rails test test/controllers/posts_controller_test.rb:15     # <-- Run this again
```

Other handy things:

* `-f` fails instantly
* `-d` defer (save output until the end—aka how it is now)
* `$ bin/rails t -n "/create/"` run based on regex
* default colored output!!

### Verbose

```
$ bin/rails t -v
Run options: -v --seed 30118

# Running:

PostsControllerTest#test_should_destroy_post = 0.07 s = .
PostsControllerTest#test_should_update_post = 0.01 s = .
PostsControllerTest#test_should_show_post = 0.10 s = .
PostsControllerTest#test_should_create_post = 0.00 s = F
```
