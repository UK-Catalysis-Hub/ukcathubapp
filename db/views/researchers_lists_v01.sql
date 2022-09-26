SELECT authors.last_name || ", " || ifnull(authors.given_name , '') AS fullname, count() AS articles, authors.orcid
  FROM authors 
  INNER JOIN article_authors ON article_authors.author_id = authors.id
  GROUP BY authors.last_name, authors.given_name, authors.orcid 
