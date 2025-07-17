require 'faker'

puts "Cleaning database..."
ItemsTag.delete_all
Item.delete_all
Category.delete_all
Collection.delete_all
User.delete_all

puts "Creating users..."

2.times do |u|
  user = User.create!(
    email: "user#{u + 1}@example.com",
    password: "password",
    username: "user#{u + 1}"
  )

  puts "Created #{user.email}"

  12.times do |c|
    collection = Collection.create!(
      name: "Collection #{c + 1} - #{user.username}",
      user: user
    )

    4.times do |cat_index|
      category = Category.create!(
        name: "Category #{cat_index + 1} for #{collection.name}",
        collection: collection
      )

      52.times do |i|
        item = Item.create!(
          name: Faker::Commerce.product_name,
          possession: rand(0..1),
          state: Item::STATE.sample,
          category: category,
          collection: collection
        )

        # To reach approx. 198 tags per user across all items, average ~4 tags per item
        rand(2..5).times do
          ItemsTag.create!(
            year: rand(1900..2025),
            name: Faker::Book.genre,
            comments: Faker::Lorem.sentence(word_count: 6),
            item: item
          )
        end
      end
    end
  end

  # Ensure exactly 198 item_tags for each user
  user_item_tags = ItemsTag.joins(item: { collection: :user }).where(collections: { user_id: user.id })
  if user_item_tags.count > 198
    excess = user_item_tags.count - 198
    ItemsTag.where(id: user_item_tags.sample(excess).map(&:id)).destroy_all
  elsif user_item_tags.count < 198
    items = Item.joins(collection: :user).where(collections: { user_id: user.id })
    (198 - user_item_tags.count).times do
      item = items.sample
      ItemsTag.create!(
        year: rand(1900..2025),
        name: Faker::Book.genre,
        comments: Faker::Lorem.sentence(word_count: 6),
        item: item
      )
    end
  end
end

puts "Seeding complete!"
