class Affiliation < ApplicationRecord
  #relationships to authors and articles
  has_many :author_affiliations
  has_many :addresses
  
  def get_addresses
    addr_list = []
    addresses.each do |affi_address|
      if not addr_list.include?(affi_address)
        addr_list.push(affi_address)
      end
    end
    addr_list.sort()
  end
  scope :country_count, -> {all.group(:country).count('*')}
  scope :filter_by_theme, -> (theme_id) {all.joins("INNER JOIN author_affiliations on author_affiliations.affiliation_id = affiliations.id").joins("INNER JOIN article_authors on author_affiliations.article_author_id = article_authors.id").joins("INNER JOIN article_themes on article_themes.article_id  = article_authors.article_id").where("article_themes.theme_id = ?", theme_id) }
end
