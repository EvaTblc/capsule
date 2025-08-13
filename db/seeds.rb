require 'faker'

puts "🧹 Cleaning database..."
ItemsTag.delete_all
Item.delete_all
Category.delete_all
Collection.delete_all
User.delete_all

puts "📸 Loading local photos..."
photos_path = Rails.root.join('db/photos')
photo_files = Dir[photos_path.join('seed*.jpg')]

puts "👤 Creating demo user..."

user = User.create!(
  email: "user1@example.com",
  password: "password",
  username: "user1"
)
puts "✅ User #{user.email} created"

puts "📦 Creating collections"

3.times do |c|
  collection = Collection.create!(
    name: "Collection #{c + 1} - #{user.username}",
    user: user
  )
end

puts "✅ Seed complete! (Light mode)"
