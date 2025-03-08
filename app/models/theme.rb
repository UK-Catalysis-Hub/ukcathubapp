class Theme < ApplicationRecord
  has_many :article_themes
  has_many :articles, through: :article_themes
end
