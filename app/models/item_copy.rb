class ItemCopy < ApplicationRecord
  belongs_to :item

  STATE = [ "Neuf", "Très bon état", "Bon état", "Occasion", "Abimé" ]
  validates :state, inclusion: { in: STATE }
end
