class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :collections

  has_one_attached :avatar

  def self.from_omniauth(auth)
    # First try to find by provider and uid
    user = where(provider: auth.provider, uid: auth.uid).first
    return user if user

    # If not found, check if user exists by email and link the account
    user = find_by(email: auth.info.email)
    if user
      user.update(
        provider: auth.provider,
        uid: auth.uid,
        full_name: auth.info.name,
        avatar_url: auth.info.image
      )
      return user
    end

    # Create new user if none exists
    create!(
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider,
      uid: auth.uid,
      full_name: auth.info.name,
      avatar_url: auth.info.image
    )
  end
end
