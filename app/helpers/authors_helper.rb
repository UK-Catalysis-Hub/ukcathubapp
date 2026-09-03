module AuthorsHelper
  def get_theme_links
    themes_list = []
    themes_list_lnks = ""
    @author.articles.each do |art|
      art.article_themes.each do |art_theme|
        if not themes_list.include?(art_theme.theme.short) then
          themes_list.push(art_theme.theme.short)
          if themes_list_lnks == "" then
            themes_list_lnks = link_to(art_theme.theme.short, art_theme.theme)
          else
            themes_list_lnks += ", ".html_safe + link_to(art_theme.theme.short, art_theme.theme)
          end
        end
      end
    end
    themes_list_lnks
  end

  def get_affiliation_links
    affiliation = []
    affiliation_links = ""
    @author.affiliations.each do |afi|
      if not affiliation.include?(afi.organisation) then
        affiliation.push(afi.organisation)
        if affiliation_links == "" then
          affiliation_links = link_to(afi.organisation.name, afi.organisation)
        else
          affiliation_links += ", ".html_safe + link_to(afi.organisation.name, afi.organisation)
        end
      end
    end
    affiliation_links 
  end
end
