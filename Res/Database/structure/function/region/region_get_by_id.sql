SELECT c.region_id,
	   c.country_id,
       c.region_name,
	   c.is_sea
FROM region AS c
   INNER JOIN _params AS p 
        ON p.column1 = c.region_id;