# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding Application Congfiguration..."
load Rails.root.join('db', 'seeds', 'app_config.rb')

puts "Seeding sections..."
load Rails.root.join('db', 'seeds', 'sections.rb')

puts "Seeding Organisations..."
load Rails.root.join('db', 'seeds', 'organisations.rb')

puts "Seeding crossref mappings..."
load Rails.root.join('db', 'seeds', 'xref_mappings.rb')

Address.create(add_01:"Phisical Sciences Data Infrastructure",
      add_02:"Scientific Computing Department, Rutherford Appleton Laboratory",
      add_03:"Science and Technology Facilities Council",
      add_04:"OX11 0QX",
      city:"Didcot",
      province:"England",
      country:"United Kingdom",
      affiliation_id:0)

