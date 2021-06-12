class Allocation < ApplicationRecord
  belongs_to :grant

  validates :host, presence: true
  validates :vcpu, presence: true
end
