class Item < ApplicationRecord

  belongs_to :category
  belongs_to :collection
  has_many :items_tags

  accepts_nested_attributes_for :items_tags, allow_destroy: true

  has_many_attached :photos

  STATE = [ "Neuf", "Très bon état", "Bon état", "Occasion", "Abimé" ]
  validates :state, inclusion: { in: Item::STATE }

end
