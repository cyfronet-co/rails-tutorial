class Grant < ApplicationRecord
  include Sluggable

  has_rich_text :content
  has_many_attached :documents
  has_many :allocations, dependent: :destroy
  belongs_to :user

  validates :title, presence: true
  validates :name, presence: true

  after_save :log_creation
  broadcasts
  after_create_commit -> do
    GrantMailer.grant_created(self).deliver_now
    GrantIndexerJob.perform_later(self)
  end

  def to_param
    slug || id.to_s
  end

  private
    def log_creation
      logger.info("New article: #{title} created")
    end
end
