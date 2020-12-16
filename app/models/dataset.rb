class Dataset < ApplicationRecord
  #relationships to articles
  has_many :article_datasets
  has_many :articles, through: :article_datasets

  #scopes for datsets
  scope :latest, -> {order('dataset_startdate DESC').order('id DESC').limit(10)  }
  scope :repository_count, -> {select("repository, COUNT(*) AS 'r_count'").order("r_count DESC").group("repository")}
  scope :ds_per_year, -> {select("strftime('%Y', dataset_startdate) AS item, COUNT(*) AS 'i_count'").group("item")}
end
