class Theme < ApplicationRecord
  has_many :article_themes
  has_many :articles, through: :article_themes
  # custom method to get the list of authors for a given theme
  def get_authors
    authors = []
    articles.each do |article|
      article.authors.each do |author|
        if not authors.include?(author) then
          authors.push(author)
        end
      end
    end
    authors
  end
end
