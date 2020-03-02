class Article < ApplicationRecord
  # relationships to authors
  has_many :article_authors
  has_many :authors, through: :article_authors

  # relationships to themes
  has_many :article_themes
  has_many :themes, through: :article_themes

  # relationships to affiliations
  has_many :affiliation_links
  has_many :affiliations, through: :affiliation_links
end
