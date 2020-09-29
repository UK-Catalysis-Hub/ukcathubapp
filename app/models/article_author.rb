class ArticleAuthor < ApplicationRecord
  belongs_to :author
  belongs_to :article
  has_many :cr_affiliations
  has_many :author_affiliations
  # scopes
  scope :not_verified, -> {where("status is not 'verified'") }
  scope :verified, -> {where("status is 'verified'") }
end
