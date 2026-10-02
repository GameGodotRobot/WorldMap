SELECT c.country_id,
       c.country_name
FROM country AS c
   INNER JOIN _params AS p 
        ON p.column1 = c.country_id;