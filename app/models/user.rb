class User < ApplicationRecord
  has_many :grants, dependent: :destroy
end
