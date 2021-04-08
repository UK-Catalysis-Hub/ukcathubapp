class Theme < ApplicationRecord
  has_many :article_themes
  has_many :articles, through: :article_themes
  # custom method to get the list of authors for a given theme
  def get_authors
    author_list = []
    articles.each do |article|
      article.authors.each do |author|
        if not author_list.include?(author) and author.isap then
          author_list.push(author)
        end
      end
    end
    author_list
  end
  def get_affiliations
    affi_list = []
    author_list = get_authors
    author_list.each do |author|
      author.affiliations.each do |affiliation|
        if not affi_list.include?(affiliation)
          affi_list.push(affiliation)
        end
      end
    end
    Affiliation.filter_by_theme(self.id)
  end
end
