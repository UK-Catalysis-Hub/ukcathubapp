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
  scope :isap, -> {where("authors.isap = 1")}
  scope :not_verified, -> {joins("INNER JOIN article_authors ON article_authors.author_id = authors.id").where("article_authors.status is not 'verified'") }
  scope :active, -> {joins(:articles).select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, COUNT(*) AS 'pub_count', authors.orcid").where("articles.status = 'Added'").group("authors.id")}
  scope :publications_count, -> {isap.joins(:articles).select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, COUNT(*) AS 'pub_count', authors.orcid").order("pub_count DESC").group("authors.given_name, authors.last_name")}
  scope :data_objects_count, -> {isap.joins(:articles).joins("INNER JOIN article_datasets ON article_datasets.article_id = articles.id").where("article_datasets.article_id = articles.id").select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, COUNT(*) AS 'pub_count'").order("pub_count DESC").group("authors.given_name, authors.last_name")}
  scope :citations_count, -> {isap.joins(:articles).select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, SUM(articles.referenced_by_count) AS 'Citations'").order("Citations DESC").group("authors.given_name, authors.last_name")}
  scope :country_count, -> {Author.joins(:author_affiliations).select('author_affiliations.country').group(:country).count('*')}
  def get_full
    full_n = (self.given_name == NIL ? self.last_name : self.last_name + ", " +self.given_name) 
    return full_n
  end
end
