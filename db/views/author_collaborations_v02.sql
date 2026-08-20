SELECT 
  a1.author_id as author_source, a2.author_id as author_target, 
  count(*) AS weight
FROM
  article_authors a1
  JOIN article_authors a2
  ON a1.article_id = a2.article_id
  AND a1.author_id < a2.author_id
GROUP BY
  a1.author_id,
  a2.author_id
