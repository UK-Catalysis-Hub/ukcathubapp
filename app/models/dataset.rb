class Dataset < ApplicationRecord
  #relationships to articles
  has_many :article_datasets
  has_many :articles, through: :article_datasets
end
