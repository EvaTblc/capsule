class Category < ApplicationRecord
  belongs_to :collection
  has_many :items

  NAME = [ "Livre", "Jouet", "Film", "Jeux Vidéo", "Autres" ]
  # validates :name, inclusion: { in: Category::NAME }
end
