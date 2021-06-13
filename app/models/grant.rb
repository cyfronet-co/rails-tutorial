class Grant < ApplicationRecord
  has_rich_text :content
  has_many_attached :documents
  has_many :allocations, dependent: :destroy
  belongs_to :user

  validates :title, presence: true
  validates :name, presence: true

  after_save :log_creation
  broadcasts

  private
    def log_creation
      logger.info("New article: #{title} created")
    end
end
