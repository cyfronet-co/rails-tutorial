# Rails tutorial - let's create simple bazar in 3h

The repository stores code used during rails tutorial for CO team.

## Ruby basics
  * Show module, class, method, inheritance, `attr_*`
  * Show `do_that if somethid?`
  * Show console

## Rails
  * [Basics](docs/basics.md):
    - Create simple MVC application (with postgresql as a backend)
    - Create first static webpage (show how routing works)
    - Add dynamic content (e.g. Time.now)
    - Move dynamic content into controller
    - Create first entity (e.g. Article) with CRUD
    - Active Text
    - Active Storage
    - Nested resources
    - I18n
    - Console
  * [Hotwire](docs/hotwire.md)
    - turbo frame
    - turbo stream
    - Not hotwire but nice to introduce now: counter cache
    - Live updated though websockets
  * [Authentication & Authorization](docs/aa.md)
    - omniauth and PLGrid keycloak configuration
    - [rails credentials](https://blog.saeloun.com/2019/10/10/rails-6-adds-support-for-multi-environment-credentials.html)
    - Pundit for authorization
  * [Tests](docs/tests.md)
    - Model tests (test Grant slugable)
    - Controller tests
    - System tests (mention about feature tests with JS and chrome headless)
  * [Emails](docs/emails.md)
    - Send email to Article author when new article is published
  * [Background jobs](docs/active_jobs.md)
    - Configure email async send
    - Custom background processing
  * [Views components (https://github.com/github/view_component)](docs/view_components.md)
    - Create sample component
    - Component tests
  * [Assets via webpack](docs/assets.md)
