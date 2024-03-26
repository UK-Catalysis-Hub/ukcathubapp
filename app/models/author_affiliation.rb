class AuthorAffiliation < ApplicationRecord
  belongs_to :article_author
  belongs_to :affiliation
end
