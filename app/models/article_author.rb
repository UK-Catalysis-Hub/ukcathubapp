class ArticleAuthor < ApplicationRecord
  belongs_to :author
  belongs_to :article
  has_many :cr_affiliations
end
