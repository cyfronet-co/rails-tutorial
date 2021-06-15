# Hotwire (https://hotwire.dev)

Add hotwire dependency (`gem 'hotwire-rails'`) to `Gemfile` and remove
`turbolinks` from `Gemfile`.

```
bundle install
bin/rails hotwire:install
bin/rails restart
```

Add turbo frame tag into grant show and edit action

`app/views/grants/show.html.erb`
```erb
<%= turbo_frame_tag :grant do %>
  <p id="notice"><%= notice %></p>
  <p>
    <strong>Title:</strong>
    <%= @grant.title %>
  </p>

  <p>
    <strong>Name:</strong>
    <%= @grant.name %>
  </p>

  <p>
    <%= @grant.content %>
  </p>

  <ul>
    <% @grant.documents.each do |document| %>
      <li>
        <%= link_to document.blob.filename, rails_blob_path(document, disposition: "attachment") %>
      </li>
    <% end %>
  </ul>

  <%= link_to 'Edit', edit_grant_path(@grant) %> |
  <%= link_to 'Back', grants_path, "data-turbo-frame": "_top" %>
<% end %>
```

`app/views/grants/edit.html.erb`
```erb
<%= turbo_frame_tag :grant do %>
  <%= render 'form', grant: @grant %>
  <%= link_to 'Show', @grant %> |
  <%= link_to 'Back', grants_path, "data-turbo-frame": "_top" %>
<% end %>
```

  * Show the difference between in place edit and full edit (using dedicated
    url) - no header in inplace edit
  * Explain `"data-turbo-frame": "_top"`

## Allocation creation in place

Change "New allocation link into (`app/views/grants/show.html.erb`):
```erb
<%= turbo_frame_tag "new_allocation", src: new_grant_allocation_path(@grant),
target: "_top" %>
```

Add `turbo_frame_tag` to `app/views/allocation/new.html.erb`:
```erb
<%= turbo_frame_tag "new_allocation", target: "_top" do %>
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
<% end %>
```

  * Explain lazy frame loading and why `target: "_top"` is needed

### Update allocations list by turbo stream

Wrap allocations list with turbo frame (`app/views/grants/show.html.erb`):
```erb
<%= turbo_frame_tag "allocations" do %>
  <%= render @grant.allocations %>
<% end %>
```

Change `AllocationsController#create` action
(`app/controllers/allocations_controller.rb`):

```ruby
def create
  @allocation = @grant.allocations.new(allocation_params)

  respond_to do |format|
    if @allocation.save
      format.turbo_stream
      format.html { redirect_to @grant }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Create turbo stream response (`app/views/allocations/create.turbo_stream.erb`):
```erb
<%= turbo_stream.append "allocations", @allocation %>
```

  * Explain the convention used to render allocation partial

**Problem**: form is not reset - let's try to fix it by defining reset stimulus
controller (`app/javascript/controllers/reset_form_controller.js`):

```js
import { Controller } from "stimulus"

export default class extends Controller {
  reset() {
    this.element.reset()
  }
}
```

Change new allocation form into (`app/views/allocations/new.html.erb`(:
```erb
<%= form_with(model: [@allocation.grant, @allocation],
  data: { controller: "reset-form", action: "turbo:submit-end->reset-form#reset" }) do |form| %>
  <div class="field">
    <%= form.label :host %>
    <%= form.text_field :host %>
  </div>

  <div class="field">
    <%= form.label :vcpu %>
    <%= form.text_field :vcpu %>
  </div>

  <%= form.submit "Create", data: { disable_with: false } %>
<% end %>
```

  * Explain how stimulus controllers are connected with dom elements.

## It would be nice to have allocations count

Change `app/views/grants/show.html.erb` allocations `h1` into:

```erb
<h1>
  Allocations
  (<%= @grant.allocations.size %>)
</h1>
```

**Problem**: count is not updated when new allocation is created - turbo frame
to the rescue.

Wrap count calculation with turbo frame (`app/views/grants/show.html.erb`):
```erb
<h1>
  Allocations
  <%= turbo_frame_tag "allocations_count" do %>
    (<%= @grant.allocations.size %>)
  <% end %>
</h1>
```

Add new turbo stream to `app/views/allocations/create.turbo_stream.erb`:
```erb
<%= turbo_stream.replace "allocations_count" do %>
  (<%= @allocation.grant.allocations.size %>)
<% end %>
```

**New problem** we have additional `count` DB query - solution: counter cache.

Add `allocations_count` field into `grants` table:
```
rails generate migration AddAllocationsCountToGrants allocations_count:integer
```

Modify `Allocation#grant` relation (`app/models/allocation.rb`):
```ruby
class Allocation < ApplicationRecord
  belongs_to :grant, counter_cache: true
  #...
end
```

  * Explain when counter cache can be used (e.g. show all grants and number of
    allocations on index view)

## Live updates

Uncomment redis gem in `Gemfile`. Add websocket connection into grant show page
(`app/views/grants/show.html.erb`):
```erb
<%= turbo_stream_from @grant %>
```

Broadcast when a new allocation is created (`app/models/allocation.rb`):
```ruby
class Allocation < ApplicationRecord
  #...

  after_create_commit -> { broadcast_append_to grant }
end
```

**Problem**: entries are duplicated on the view. Solution - remove append action
from `app/views/allocations/create.turbo_stream.erb` and use only websockets.

There are additional actions you can add to your model:

```ruby
class Allocation < ApplicationRecord
  #...

  after_create_commit -> { broadcast_append_to grant }
  after_destroy_commit -> { broadcast_remove_to grant }
  after_update_commit -> { broadcast_replace_to grant }
end
```

or simply:

```ruby
class Allocation < ApplicationRecord
  #...

  broadcasts_to :grant
end
```

  * Show create, update, destroy from console
  * Mention that these updates are done in async way (ActiveJob - we will be
    talking about this latter on)

Last hotwire thing: broadcast grant edit to all opened browsers
(`app/models/grant.rb`):
```ruby
class Grant < ApplicationRecord
  #...

  broadcasts
end
```

Extract grant show into `app/views/grants/_grant.html.erb`:
```erb
<div id="<%= dom_id grant %>">
  <p>
    <strong>Title:</strong>
    <%= grant.title %>
  </p>

  <p>
    <strong>Name:</strong>
    <%= grant.name %>
  </p>

  <p>
    <%= grant.content %>
  </p>

  <ul>
    <% grant.documents.each do |document| %>
      <li>
        <%= link_to document.blob.filename, rails_blob_path(document, disposition: "attachment") %>
      </li>
    <% end %>
  </ul>
</div>
```

`app/views/grants/show.html.erb`:
```erb
<%= turbo_frame_tag :grant do %>
  <p id="notice"><%= notice %></p>
  <%= render @grant %>
  <%= link_to 'Edit', edit_grant_path(@grant) %> |
  <%= link_to 'Back', grants_path, "data-turbo-frame": "_top" %>
<% end %>
```
