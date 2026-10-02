INSERT INTO region_neighbour_connect (
    region_id,
	neighbour_region_id,
    sea_distance,
	land_distance
)
SELECT p.column1,
       p.column2,
       p.column3,
       p.column4
FROM _params AS p
   LEFT JOIN region_neighbour_connect AS c
       ON p.column1 = c.region_id
	         AND p.column2 = c.neighbour_region_id
WHERE c.region_id IS NULL;