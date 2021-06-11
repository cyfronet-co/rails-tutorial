class Grant < ApplicationRecord
  validates :title, presence: true
  validates :name, presence: true

  after_save :log_creation

  private
    def log_creation
      logger.info("New article: #{title} created")
    end
end
