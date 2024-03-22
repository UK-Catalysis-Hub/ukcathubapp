SELECT country, count() as inst_count, SUM(res_count) as res_count, sum(pub_count)  AS pub_count 
	FROM (SELECT country, affi_name, COUNT(*) as res_count, sum(pub_count)  AS pub_count
		FROM (SELECT author_id, country, short_name AS affi_name, COUNT(*) AS pub_count
			FROM "authors" 
			INNER JOIN article_authors ON article_authors.author_id = authors.id 
			INNER JOIN author_affiliations ON author_affiliations.article_author_id = article_authors.id 
			GROUP BY author_id, short_name, country)
		GROUP BY country, affi_name)
	GROUP BY country
