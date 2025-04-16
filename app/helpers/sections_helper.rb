module SectionsHelper
  # Methods to fetch section data
  def get_article_section
    Section.where("obj_name='Articles'")[0]
  end

  def get_author_section
    Section.where("obj_name='Authors'")[0]
  end

  def get_affiliation_section
    Section.where("obj_name='Affiliations'")[0]
  end

  def get_theme_section
    Section.where("obj_name='Themes'")[0]
  end

  def get_do_section
    Section.where("obj_name='Datasets'")[0]
  end
  
  def get_home_section
    Section.where("obj_name='Home'")[0]
  end
  
  def get_new_pubs_section
    new_pubs = Section.new()
    new_pubs.obj_name = "cr_publications"
    new_pubs.heading = "Publications from Crossref"
    new_pubs.description = "<p>The tabs show publications found in crossref.</p> <ul><li>Pending ones can be assigned a theme and added to DB.</li><li>Rejected ones can be revised and added later</li></ul>"
    new_pubs
  end
end
