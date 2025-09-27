class Item < ApplicationRecord
  before_validation :ensure_metadata
  belongs_to :category
  belongs_to :collection
  has_many :items_tags, dependent: :destroy
  has_many :item_copies, dependent: :destroy

  accepts_nested_attributes_for :items_tags, allow_destroy: true
  accepts_nested_attributes_for :item_copies, allow_destroy: true, reject_if: :all_blank

  has_many_attached :photos do |attachable|
    attachable.variant :small, resize_to_limit: [ 1920, 1080 ], saver: { quality: 80 }
  end

  enum status: { owned: 0, wanted: 1 }

  STATE = [ "Neuf", "Très bon état", "Bon état", "Occasion", "Abimé" ]
  # validates :state, inclusion: { in: Item::STATE }

  def ensure_metadata
    self.metadata ||= {}
  end

  # Helper method to get total count of owned copies
  def total_copies
    item_copies.count
  end

  # Helper method to get copies by state
  def copies_by_state
    item_copies.group(:state).count
  end
end
