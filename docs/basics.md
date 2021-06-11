# Basics

## Creating new rails application

Create new rails application with PostgreSQL database connector

```
rails new bazar --database=postgresql
rails db:create
rails db:migrate
```

Start new created application

```
./bin/rails server
```

Describe what is generated. Don't forget to mentions about:

  * controllers
  * views
  * layouts
  * models
  * assets

## First webpage

```
rails generate controller Welcome index
```

* Show `app/controller/welcome_controller.rb` and
  `app/views/welcome/index.html.erb`
* Show `config/routes.rb`
* Add `welcome#index` as root route

## Dynamic content

Edit `app/views/welcome/index.html.erb` and change `<p>` tag into:

```erb
<p><%= Time.now %></p>
```

Show I18n.l

```erb
<p><%= l Time.now %></p>
```

Explain why login in view is wrong and move it into controller:

`app/views/welcome/index.html.erb`:

```erb
<p><%= @now %></p>
```

`app/controllers/welcome_controller.rb`

```ruby
def index
  @now = Time.now
end
```

Explain what is the difference between `variable_name` and `@variable_name`.

## CRUD

Run

```
rails g scaffold Grant title:string name:string
rails db:migrate
```

* Play with CRUD a bit
* Show what is generated
* Explain migrations
* Show routes and output of `rails routes`
* Explain paths/urls generation (e.g. `root_path`, `grants_path`,
  `edit_grant_path(@grant)`
* Show article json

Add grant `title` and `name` validation (in `app/models/grant.rb`):

```ruby
class Grant < ApplicationRecord
  validates :title, presence: true
  validates :name, presence: true

  after_save :log_creation

  private
    def log_creation
      logger.info("New article: #{title} created")
    end
end
```

* Explain validation
* Explain callbacks and why callbacks should be used with care

