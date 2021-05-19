SELECT country, COUNT() AS insts, SUM(collaborations) AS collab from(
SELECT affiliations.institution, affiliations.country , COUNT(*) AS collaborations
  FROM "authors" 
  INNER JOIN "affiliation_links" ON "affiliation_links"."author_id" = "authors"."id" 
  INNER JOIN "affiliations" ON "affiliations"."id" = "affiliation_links"."affiliation_id" 
  GROUP BY "country", affiliations.institution
)
GROUP BY country
