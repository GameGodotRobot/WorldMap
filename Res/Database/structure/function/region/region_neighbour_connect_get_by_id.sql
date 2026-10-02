SELECT c.region_id,
	   c.neighbour_region_id,
       c.sea_distance,
	   c.land_distance
FROM region_neighbour_connect AS c
   INNER JOIN _params AS p 
        ON p.column1 = c.region_id
ORDER BY c.neighbour_region_id ASC;