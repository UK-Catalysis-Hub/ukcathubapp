class Address < ApplicationRecord
  has_many :affiliation_links
  has_many :affiliations, through: :affiliation_links
end
