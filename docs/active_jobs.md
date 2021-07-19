# Active jobs

Since ruby has GIT (global interpreter lock) some of time consuming tasks (e.g.
email sending) should be moved into separate thread.

## Sidekiq

Add new dependency to your `Gemfile`
```ruby
gem 'sidekiq'
```

Now we need to tell rails that we want to use it as our delayed job executor.
Create `config/initializers/active_job.rb`:
```ruby
ActiveJob::Base.queue_adapter = :sidekiq
```
Since sidekiq is running as a separate process we need to start it once we are
starting our application. To simplify this process we can use
[`overmind`](https://github.com/DarthSim/overmind) - a process manager for
Procfile-based applications.

Now we can create Procfile configuration (`Procfile`):
```
web: PORT=3000 rails server
jobs: bundle exec sidekiq -q default
```

Now we can modify our code to use active jobs. Change
`app/controllers/atricles_controller.rb`:
```ruby
GrantMailer.grant_created(self).deliver_later
```

*Note*: Mention about arguments serialization.

And start application:
```
overmind start
```

## Defining new active job

```
rails generate job grant_indexer
```

Create simple implementation (`app/jobs/grant_indexer_job.rb`):
```ruby
class GrantIndexerJob < ApplicationJob
  queue_as :default

  def perform(grant)
    Rails.logger.info("Indexer mock invoked for #{grant.title}")
  end
end
```

Now we can invoke this job when grant is created (`app/models/grant.rb`):
```
after_create_commit -> do
  GrantMailer.grant_created(self).deliver_later
  GrantIndexerJob.perform_later(self)
end
```

## Testing

To make sure that no active job is performed during the tests add
(`test/test_helper.rb`):
```ruby
require "sidekiq/testing"
```

To test that active job is scheduled you should include to your test:
```ruby
include ActiveJob::TestHelper
```

and next you can use following assertions:
```ruby
ssert_enqueued_with(job: GrantIndexerJob, args: [grants("one")])
```
