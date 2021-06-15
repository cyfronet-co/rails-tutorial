# View components

A framework for building reusable, testable & encapsulated view components in
Ruby on Rails by Github.

## Example based on official documentation

Add view component gem into `Gemfile`:
```ruby
gem "view_component", require: "view_component/engine"
```

Generate example component

```
bundle install
bin/rails generate component Example title
```

  * Explain what is generated
  * Explain testing in isolation

Edit component template (`app/components/example_component.rb`):
```erb
<span title="<%= @title %>"><%= content %></span>p>
```

And render this component (`app/views/welcome/index.html.erb`):
```erb
<%= render(ExampleComponent.new(title: "my title")) do %>
  Hello, World!
<% end %>
```

We can also test it (`test/components/example_component_test.rb`):
```ruby
class ExampleComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    render_inline(ExampleComponent.new(title: "my title")) { "Hello, World!" }

    assert_text("Hello, World!")
  end
end
```
