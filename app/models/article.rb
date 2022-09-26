class Article < ApplicationRecord

  # relationships to authors
  has_many :article_authors
  has_many :authors, through: :article_authors

  # relationships to themes
  has_many :article_themes
  has_many :themes, through: :article_themes

  #relationships to dataset
  has_many :article_datasets
  has_many :datasets, through: :article_datasets

  scope :active, -> {where(status: "Added")  }
  scope :inactive, -> {where("status <> ?", "Added")  }
  scope :latest, -> {where(status: "Added").order("pub_year DESC").order('id DESC').limit(10)  }
  scope :most_cited, -> {where(status: "Added").order('referenced_by_count DESC').order('id DESC').limit(10) }
  scope :journals_count, -> {active.select("container_title, COUNT(*) AS 'j_count'").order("j_count DESC").group("container_title")}
  scope :publisher_count, -> {active.select("publisher, COUNT(*) AS 'p_count'").order("p_count DESC").group("publisher")}
end
