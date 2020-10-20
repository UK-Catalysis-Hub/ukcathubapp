SELECT themes.id, themes.phase, themes.name, themes.short, themes.lead, count() AS article_count
  FROM article_themes
  INNER JOIN themes on article_themes.theme_id = themes.id
  INNER JOIN articles on article_themes.article_id = articles.id
  WHERE articles.status == 'Added'
  GROUP BY themes.phase, themes.name
  ORDER BY themes.id
