class Category < ApplicationRecord
  belongs_to :collection
  has_many :items
end
