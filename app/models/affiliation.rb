class Affiliation < ApplicationRecord
  #relationships to authors and articles
  has_many :affiliation_links
  has_many :authors, through: :affiliation_links
  has_many :articles, through: :affiliation_links
  has_many :addresses, through: :affiliation_links
end
