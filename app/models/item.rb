class Item < ApplicationRecord

  belongs_to :category
  belongs_to :collection
  has_many :items_tags

  has_many_attached :photos

  STATE = [ "Neuf", "Très bon état", "Bon état", "Occasion", "Abimé" ]
  validates :state, inclusion: { in: Item::STATE }

end
