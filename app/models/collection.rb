class Collection < ApplicationRecord
  belongs_to :user
  has_many :items
  has_many :categories
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user

  # has_one_attached :image

  # Vérifie si un user est le owner
  def owner?(user)
    return false unless user
    self.user_id == user.id
  end

  # Vérifie si un user est collaborateur
  def collaborator?(user)
    return false unless user
    collaborations.exists?(user_id: user.id)
  end

  # Vérifie si un user peut voir la collection
  def viewable_by?(user)
    return false unless user
    owner?(user) || collaborator?(user)
  end

  # Vérifie si un user peut éditer (ajouter/modifier des items)
  def editable_by?(user)
    return false unless user
    return true if owner?(user)

    collaboration = collaborations.find_by(user_id: user.id)
    collaboration&.editor? || collaboration&.admin?
  end

  # Vérifie si un user peut gérer (modifier settings, inviter des collaborateurs)
  def manageable_by?(user)
    return false unless user
    return true if owner?(user)

    collaboration = collaborations.find_by(user_id: user.id)
    collaboration&.admin?
  end

  # Vérifie si un user peut supprimer
  def destroyable_by?(user)
    owner?(user)
  end
end
