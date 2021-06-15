class GrantIndexerJob < ApplicationJob
  queue_as :default

  def perform(grant)
    Rails.logger.info("Indexer mock invoked for #{grant.title}")
  end
end
