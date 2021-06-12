class Allocation < ApplicationRecord
  belongs_to :grant, counter_cache: true

  validates :host, presence: true
  validates :vcpu, presence: true

  broadcasts_to :grant
end
