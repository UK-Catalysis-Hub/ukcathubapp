class Article < ApplicationRecord
  has_many :article_authors
  has_many :authors, through: :article_authors
end
