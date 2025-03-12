module SectionsHelper

  def get_article_data
    # Fetch your model data here
    Section.where("obj_name='Articles'")[0]
  end

  def get_author_data
    # Fetch your model data here
    Section.where("obj_name='Authors'")[0]
  end

  def get_affiliation_data
    # Fetch your model data here
    Section.where("obj_name='Affiliations'")[0]
  end

  def get_theme_data
    # Fetch your model data here
    Section.where("obj_name='Themes'")[0]
  end

  def get_do_data
    # Fetch your model data here
    Section.where("obj_name='Datasets'")[0]
  end
end
