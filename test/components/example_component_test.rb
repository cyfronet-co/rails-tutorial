require "test_helper"

class ExampleComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    render_inline(ExampleComponent.new(title: "my title")) { "Hello, World!" }

    assert_text("Hello, World!")
  end
end
