class ArticleTheme < ApplicationRecord
  belongs_to :theme
  belongs_to :article
end
