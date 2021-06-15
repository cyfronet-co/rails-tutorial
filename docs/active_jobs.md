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
ActiveJob::Base.queue_adapter = Rails.env.test? ? :inline : :sidekiq
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
  GrantMailer.grant_created(self).deliver_now
  GrantIndexerJob.perform_later(self)
end
```
