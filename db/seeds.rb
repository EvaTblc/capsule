require 'faker'

puts "🧹 Cleaning database..."
ItemsTag.delete_all
ItemCopy.delete_all
Item.delete_all
Category.delete_all
Collection.delete_all
User.delete_all


puts "✅ Everythings clean !"
