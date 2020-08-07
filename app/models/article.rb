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

  #relationships to dataset
  has_many :article_datasets
  has_many :datasets, through: :article_datasets

  scope :active, -> {where(status: "Added")  }
  scope :latest, -> {where(status: "Added").order('CASE WHEN Articles.pub_ol_year = "" THEN Articles.pub_print_year ELSE Articles.pub_ol_year END DESC').order('id DESC').limit(10)  }
  scope :most_cited, -> {where(status: "Added").order('reference_count DESC').order('id DESC').limit(10) }
end
