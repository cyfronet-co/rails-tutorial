# Testing

  * Fix fixtures
  * Remove welcome controller test since we don't have welcome route
  * It seems like `gem 'rexml'` gem needs to be added to Gemfile in order to run
    tests


## Fix existing tests

`test/fixtures/users.yml`
```yaml
john:
  uid: johnuid
  name: John Doe
  email: john@doe.local
```

`test/fixtures/grants.yml`
```yml
one:
  title: MyString
  name: MyString
  user: john
```

For now comment fixtures in `test/fixtures/allocations.yml`

Add to `test/test_helper.rb`:
```ruby
OmniAuth.config.test_mode = true

def sign_in_as(name)
  user = users(name)
  OmniAuth.config.add_mock(
    "plgrid",
    uid: user.uid,
    info: {
      name: user.name,
      email: user.email
    }
  )
  get "/auth/plgrid/callback"
end
```

Add `sign_in_as("john")` into controllers and system tests.
```ruby
setup do
  @grant = grants(:one)
  sign_in_as("john")
end
```

  * Show different type of tests (start with high level system test and go down
    into model test)

## Our first custom feature - slugable grant name

### Model test

At the beginning create test with behavior you wish to have, don't think about
implementation (`test/models/grant_test.rb`):
```ruby
class GrantTest < ActiveSupport::TestCase
  test "slug is created after grant is saved into db" do
    grant = Grant.create!(
      user: users("john"), title: "My precious grant", name: "my previous!!!")

    assert_equal "my-precious", grant.slug, "Slug was wrongly generated"
  end
end
```

run this test:
```
bin/rails test test/models/grant_test.rb
```

The result is as follow:
```
unning via Spring preloader in process 1929442
Run options: --seed 20316

# Running:

E

Error:
GrantTest#test_slug_is_created_after_grant_is_saved_into_db:
NoMethodError: undefined method `slug' for #<Grant id: 980190963, title: "My precious grant", name: "my previous!!!", created_at: "2021-06-15 10:21:32.876189000 +0000", updated_at: "2021-06-15 10:21:32.876189000 +0000", allocations_count: nil, user_id: 830138774>
    test/models/grant_test.rb:8:in `block in <class:GrantTest>'


rails test test/models/grant_test.rb:4



Finished in 0.408150s, 2.4501 runs/s, 0.0000 assertions/s.
1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
```

To solve this problem we need to create new migration which adds this field:
```
rails generate migration AddSlugToGrant slug:string:uniq
```

Run migration and tests once again:
```
bin/rails db:migrate
bin/rails test test/models/grant_test.rb
```

```
Running via Spring preloader in process 1935917
Run options: --seed 36528

# Running:

F

Failure:
GrantTest#test_slug_is_created_after_grant_is_saved_into_db
[/home/marek/playground/ror/bazar/test/models/grant_test.rb:8]:
Slug was wrongly generated.
Expected: "my-precious"
  Actual: nil

```

Lets try to fix this by adding slug generation before db record is created
(`app/models/grant.rb`):
```ruby
class Grant < ApplicationRecord
  before_create :slugify

  #...

  private
    def slugify
      self.slug = title.to_s.parameterize
    end

    #...
end
```
Now it is much better
```
bin/rails test test/models/grant_test.rb
```

```
Running via Spring preloader in process 1955915
Run options: --seed 17722

# Running:

.

Finished in 0.504014s, 1.9841 runs/s, 1.9841 assertions/s.
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Slugable is quite generic thing which does not fit into grant class. Lets try
to externalize it into "concern" (`app/models/concerns/slugable.rb`):
```ruby
module Slugable
    extend ActiveSupport::Concern

    included do
      before_create :slugify
    end

    private
      def slugify
        self.slug = name.to_s.parameterize
      end
end
```

We also need to add slug into grant fixtures (**explain why**):
```
one:
  title: MyString
  name: MyString
  slug: mystring
  user: john
```

and eliminate potential unique errors from the controller and system tests (edit
`test/controllers/grants_controller_test.rb` and `test/system/grants_test.rb`).

To use new created slug field instead of id field add following method into
Grant model (`app/models/grant.rb`):
```ruby
def to_param
  slug || id.to_s
end
```
After running tests and system tests (`bin/rails test; bin/rails test:system`) we can see a
lot of errors. Let's try to fix it.

`app/controllers/grants_controller.rb`
```ruby
def set_and_authorize_grant
  @grant = Grant.find_by(slug: params[:id]) || Grant.find(params[:id])
  authorize(@grant)

  @grant
end
```

`app/controllers/allocations_controller.rb`
```ruby
def set_grant
  @grant = Grant.find_by(slug: params[:grant_id]) || Grant.find(params[:grant_id])
end
```
