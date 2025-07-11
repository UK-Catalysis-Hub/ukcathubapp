module ThemesHelper
  def get_theme_groupings()
    x = Theme.group(:theme_type, :phase).order(:phase).count.to_a
    return x.map {|(thm,thmty),thmc |[thm,thmty,thmc]}
  end
end
