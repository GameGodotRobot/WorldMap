INSERT INTO country (
    country_id,
    country_name,
	finance
)
SELECT p.column1,
       p.column2,
	   0 finance
FROM _params AS p
   LEFT JOIN country AS c
       ON p.column1 = c.country_id
WHERE c.country_id IS NULL;