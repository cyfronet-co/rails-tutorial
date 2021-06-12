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

## Active Text

Run

```
bin/rails action_text:install
```

Add `has_rich_text :content` to `Grant` model class.

```ruby
class Grant < ApplicationRecord
  has_rich_text :content
  #...
end
```

Add new form element (`app/views/grants/_form.html.erb`)

```erb
<div class="field">
  <%= form.label :content %>
  <%= form.rich_text_area :content %>
</div>
```

Change `GrantsController#grant_params` (`app/controllers/grants_controller.rb`)
into:

```ruby
def grant_params
  params.require(:grant).permit(:title, :name, :content)
end
```

Explain strong parameters

Add content to grant show view (`app/views/grants/show.html.erb`)

```erb
<p>
  <%= @grant.content %>
</p>
```

See content and error in logs. Add missing `gem 'image_processing', '~> 1.2'`
gem into `Gemfile`. Explain `Gemfile`

```
bundle install
bin/rails restart
```

## Active Storage

Add `has_many_attached` into `Grant` model class (`app/models/grant.rb`):

```ruby
class Grant < ApplicationRecord
  has_many_attached :documents
  #...
end
```

Add to grant form (`app/views/grants/_form.html.erb`)

```erb
<div class="field">
  <%= form.label :documents %>
  <%= form.file_field :documents, multiple: true %>
</div>
```

Change `GrantsController#grant_params` into
(`app/controllers/grants_controller.rb`):

```ruby
def grant_params
  params.require(:grant).permit(:title, :name, :content, documents: [])
end
```

Show attachments on grant show view (`app/views/grants/show.html.erb`):

```erb
<ul>
  <% @grant.documents.each do |document| %>
    <li>
      <%= link_to document.blob.filename, rails_blob_path(document, disposition: "attachment") %>
    </li>
  <% end %>
</ul>
```

## Grant allocations

Create simple allocation model which references grant:

```
bin/rails generate model Allocation host:string vcpu:integer grant:references
```

Add basic validation and relation definition between grant and allocations

```ruby
# app/models/alloction.rb
class Allocation < ApplicationRecord
  belongs_to :grant

  validates :host, presence: true
  validates :vcpu, presence: true
end
```

```ruby
# app/models/alloction.rb
class Grant < ApplicationRecord
  has_many :allocations, dependent: :destroy
  #...
end
```

  * Explain `belongs_to` a `has_many`
  * Explain `dependent: :destroy`

Create routes (`config/routes.rb`)
```ruby
resources :grants do
  resources :allocations, only: [:new, :create]
end
```

  * Explain nested routes

Create controller for allocation model:

```ruby
class AllocationsController < ApplicationController
  before_action :set_grant, only: %i[ new create ]

  def new
    @allocation = @grant.allocations.new
  end

  def create
    @allocation = @grant.allocations.new(allocation_params)

    respond_to do |format|
      if @allocation.save
        format.html { redirect_to @grant }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_grant
      @grant = Grant.find(params[:grant_id])
    end

    def allocation_params
      params.require(:allocation).permit(:host, :vcpu)
    end
end
```

Create views for creating new allocation and showing existing one

`app/views/allocations/new.html.erb`
```erb
<h1>New allocation</h1>

<%= form_with(model: [@allocation.grant, @allocation]) do |form| %>
  <div class="field">
    <%= form.label :host %>
    <%= form.text_field :host %>
  </div>

  <div class="field">
    <%= form.label :vcpu %>
    <%= form.text_field :vcpu %>
  </div>

    <%= form.submit "Create" %>
<% end %>

<%= link_to "Back", @allocation.grant %>

```

`app/views/allocations/_allocations.html.erb`
```erb
<p id="<%= dom_id allocation %>">
  Allocation on <%= allocation.host %>: <%= allocation.vcpu %> vcpu.
</p>
```

Add allocations section into grant show view (`app/views/grants/show.html.erb`)
```erb
<div id="allocations">
  <h1>Allocations</h1>
  <%= render @grant.allocations %>
</div>
```

  * Explain render collection capability

## I18n

Change `app/views/welcome/index.html.erb` `h1` tag content into:

```erb
<h1><%= t 'welcome.index.title' %></h1>
```

Add missing translation o `config/locales/en.yml`:
```yaml
en:
  welcome:
    index:
      title: Bazar in 3h
```

Change `h1` tag in `app/views/welcome/index.html.haml` into:

```erb
<h1><%= t '.title' %></h1>
```

* Explain translation
* Explain local translation (with controller, action scope)

# Console

Run:

```
bin/rails console
```

and find e.g. all articles, create new article:

```
Grant.all
Grant.create(title: 'from console', name: 'plggfromconsole')
```
