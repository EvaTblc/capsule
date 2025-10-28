class Collaboration < ApplicationRecord
  belongs_to :collection
  belongs_to :user

  enum role: { viewer: 0, editor: 1, admin: 2 }

end
