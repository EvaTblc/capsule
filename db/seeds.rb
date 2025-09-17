require 'faker'

puts "🧹 Cleaning database..."
ItemsTag.delete_all
Item.delete_all
Category.delete_all
Collection.delete_all
User.delete_all

puts "👤 Creating demo user..."

user = User.create!(
  email: "user1@example.com",
  password: "password",
  username: "user1"
)

file = File.open(Rails.root.join("db/photos/seed1.jpg"))
user.avatar.attach(io: file, filename: "avatar.jpg", content_type: "image/jpeg")

puts "✅ User #{user.email} created"

puts "✅ Seed complete! (Light mode)"
