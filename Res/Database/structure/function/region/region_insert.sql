INSERT INTO region (
    region_id,
	country_id,
    region_name,
	is_sea,
	finance,
	price_tax
)
SELECT p.column1,
       p.column2,
       p.column3,
       p.column4,
	   0 finance,
	   1.2 price_tax
FROM _params AS p
   LEFT JOIN region AS c
       ON p.column1 = c.region_id
WHERE c.region_id IS NULL;