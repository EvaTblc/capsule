class Category < ApplicationRecord
  belongs_to :collection
  has_many :items

  has_one_attached :photo

  NAME = [ "Livre", "Jouet", "Film", "Jeux Vidéo", "Autres" ]
  # validates :name, inclusion: { in: Category::NAME }
end
