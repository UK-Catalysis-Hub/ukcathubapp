class Author < ApplicationRecord
  # relationships to articles
  has_many :article_authors
  has_many :articles, through: :article_authors

  #extra relationships to intermediate Crossref objects
  has_many :cr_affiliations, through: :article_authors
  has_many :author_affiliations, through: :article_authors

  # relationships to affiliations
  has_many :affiliation_links
  has_many :affiliations, through: :affiliation_links

  # scopes
  scope :not_verified, -> {joins("INNER JOIN article_authors ON article_authors.author_id = authors.id").where("article_authors.status is not 'verified'") }
  scope :top_published, -> {order('articles DESC').limit(10) }
  scope :top_published2, -> {Article.active.joins(:authors).select("authors.id, full_name, COUNT(*) AS 'article_count'").order("article_count DESC").group("authors.full_name").limit(5)}
  scope :active, -> {joins(:articles).where("articles.status = 'Added'")}
end
