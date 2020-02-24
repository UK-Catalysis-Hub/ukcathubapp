class Article < ApplicationRecord
  has_many :article_authors
  has_many :authors, through: :article_authors

  has_many :article_themes
  has_and_belongs_to_many :themes, through: :article_themes
  
end
