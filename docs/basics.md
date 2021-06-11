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

