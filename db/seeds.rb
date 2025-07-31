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

puts "📦 Creating collections, categories, items & attachments..."

3.times do |c|
  collection = Collection.create!(
    name: "Collection #{c + 1} - #{user.username}",
    user: user
  )

  2.times do |cat_index|
    category = Category.create!(
      name: Category::NAME.sample,
      collection: collection
    )

    6.times do
      item = Item.create!(
        name: Faker::Commerce.product_name,
        possession: rand(0..1),
        state: Item::STATE.sample,
        category: category,
        collection: collection
      )

      # Always attach 3 photos
      3.times do
        file_path = photo_files.sample
        item.photos.attach(
          io: File.open(file_path),
          filename: File.basename(file_path),
          content_type: 'image/jpeg'
        )
      end

      # 1 à 2 tags par item
      rand(1..2).times do
        ItemsTag.create!(
          year: rand(1900..2025),
          name: Faker::Book.genre,
          comments: Faker::Lorem.sentence(word_count: 5),
          item: item
        )
      end
    end
  end
end

puts "✅ Seed complete! (Light mode)"
