class Author < ApplicationRecord
  #relationships to articles
  has_many :article_authors
  has_many :articles, through: :article_authors

  #relationships to affiliations
  has_many :affiliation_links
  has_many :affiliations, through: :affiliation_links
end
