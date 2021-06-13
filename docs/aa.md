# Authentication and authorization

We will focus only on the integration with new Cyfronet IDP (based on
[keycloak](https://www.keycloak.org/) and [OpenId
Connect](https://openid.net/connect/). If you need basic username/password
support take a look at [Devise](https://github.com/heartcombo/devise) gem.

## OmniAuth: Standardized Multi-Provider Authentication

Generate user model
```
rails g model User uuid:string:uniq name:string
```

  * Explain different generator options (show e.g. `bin/rails generate model
    --help`

Modify user create migration and add constraint that `uuid` and `name` should be
not null (`db/migrations/timestamp_create_user.rb`)
```ruby
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end
    add_index :users, :uid, unique: true
  end
end
```

Run migrations:

```
bin/rails db:migrate
```

Add `gem 'omniauth_openid_connect'` into `Gemfile` and run

```
bundle install
```

Create `SessionsController` (`app/controllers/sessions_controller.rb`):
```ruby
class SessionsController < ApplicationController
  def create
    user = User.find_or_initialize_by(uid: auth.uid).tap do |u|
      u.name = auth.info.name
      u.email = auth.info.email
      u.save!
    end
    session[:user_id] = user.id

    redirect_to root_path, info: "Authenticated"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  private
    def auth
      request.env['omniauth.auth']
    end
end
```

Define login/logout/callback routes (`config/routes.rb`):
```ruby
delete 'logout', to: 'sessions#destroy', as: 'logout'
get 'auth/:provider/callback', to: 'sessions#create'
get 'auth/failure', to: redirect('/')
```

Add `current_user` and `authenticate_user!` methods into `ApplicationController`
(`app/controllers/application_controller.rb`):

```ruby
class ApplicationController < ActionController::Base
  helper_method :current_user

  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def authenticate_user!
      redirect_to root_path, alert: "Login is required" unless current_user
    end
end
```

  * Explain `!` and `?` methods
  * Explain the role of `ApplicationController`

And finally add login and logout links on the welcome index page
(`app/views/welcome/index.html.erb`):
```erb
<p id="alert"><%= alert %></p>

<% if current_user %>
  Welcome <%= current_user.name %>!
  <%= link_to "Sign Out", logout_path, method: :delete %>
<% else %>
  <%= link_to "Sign in by PLGrid", "/auth/plgrid" %>
<% end %>
```

To secure webpages use `authenticate_user!`:

`app/controllers/grants_controller.rb`:
```ruby
class GrantsController < ApplicationController
  before_action :authenticate_user!
  # ...
end
```

`app/controllers/allocations_controller.rb`:
```ruby
class AllocationsController < ApplicationController
  before_action :authenticate_user!
  # ...
end
```

**Problem**: A log of repetition, we can move `before_filter
:authenticate_user!` into `ApplicationController`, but we should skip it in
`WelcomeController`:

`app/controllers/application_controller.rb`
```ruby
class ApplicationController < ActionController::Base
  before_action :authentiate_user!
  #...
end
```

`app/controllers/welcome_controller.rb`
```ruby
class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!
  #...
end
```

## Rails credentials

Right now we have to set a lot of environment variables to run an application.
We can use rails credentials store to simplify application setup.

```
bin/rails credentials:edit
```

Add:

```yaml
plgrid:
  sso:
    host: ...
    identifier: ...
    secret: ...
```

  * Explain the role of `master.key`

and modify omniauth plgrid configuration (`config/initializers/plgrid.rb`):
```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :plgrid,
    scope: [:openid],
    response_type: :code,
    issuer: "https://#{Rails.application.credentials.plgrid.dig(:sso, :host)}/auth/realms/PLGRID",
    discovery: true,
    client_options: {
      port: nil,
      scheme: "https",
      host: Rails.application.credentials.plgrid.dig(:sso, :host),
      identifier: Rails.application.credentials.plgrid.dig(:sso, :identifier),
      secret: Rails.application.credentials.plgrid.dig(:sso, :secret),
      redirect_uri: "http://localhost:3000/auth/plgrid/callback"
    }
end
```

**Notice**: we can create credentials specific for the environment and e.g.
share with developer `master.key` specific only for `development` environment
and only admin will have access to `staging` and `production` `master.key`s.

```
bin/rails credentials:edit --environment production
```