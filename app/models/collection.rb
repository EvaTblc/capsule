class Collection < ApplicationRecord
  belongs_to :user
  has_many :items
  has_many :categories

  # has_one_attached :image
end
