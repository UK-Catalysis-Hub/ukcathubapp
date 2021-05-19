SELECT country, COUNT() AS insts, SUM(rchs) AS res, sum(colls) AS collab FROM(
  SELECT country, COUNT() AS rchs, SUM(publications) AS colls FROM(
    SELECT authors.id, affiliations.institution, affiliations.country, COUNT(*) AS publications
      FROM "authors" 
      INNER JOIN "affiliation_links" ON "affiliation_links"."author_id" = "authors"."id" 
      INNER JOIN "affiliations" ON "affiliations"."id" = "affiliation_links"."affiliation_id" 
      GROUP BY authors.id, affiliations.institution, affiliations.country
    )
    GROUP BY country, institution
  )
GROUP BY country
