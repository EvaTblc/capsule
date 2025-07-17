class Item < ApplicationRecord
  belongs_to :category
  belongs_to :collection
  has_many :items_tags
end
