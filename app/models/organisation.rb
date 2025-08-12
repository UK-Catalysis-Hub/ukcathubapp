class Organisation < ApplicationRecord
  has_many :affiliations
  has_many :author_affiliations, through: :affiliations
 
  scope :active_org, -> {
    joins(affiliations: :author_affiliations)
      .where.not(author_affiliations: { id: nil }).distinct
  }
end
