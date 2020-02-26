class AffiliationLink < ApplicationRecord
  belongs_to :author
  belongs_to :article
  belongs_to :affiliation
end
