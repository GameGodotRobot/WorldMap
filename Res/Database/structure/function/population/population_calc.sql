WITH cte AS (
SELECT p.region_id,
       1001 product_type_id,
       ROUND(MIN(SUM(p.female_count),SUM(p.male_count))*0.00018+0.49999999) male_count,
       ROUND(MIN(SUM(p.female_count),SUM(p.male_count))*0.00018+0.49999999) female_count    
FROM population p
WHERE p.product_type_id != 1001
GROUP BY p.region_id
UNION ALL
SELECT ph.region_id,
       1000 product_type_id,
       ph.male_count,
       ph.female_count
FROM population_history as ph
    INNER JOIN global as g
       ON g.global_id = 1
           AND ph.game_date = DATE(g.game_date, "-5 840 days")
UNION ALL
SELECT ph.region_id,
       1001 product_type_id,
       -ph.male_count,
       -ph.female_count
FROM population_history as ph
    INNER JOIN global as g
       ON g.global_id = 1
           AND ph.game_date = DATE(g.game_date, "-5 840 days")
UNION ALL
SELECT m.region_id,
       1002 product_type_id,
       MIN(500*m.manufacture_count-COALESCE(s.male_count,0), p.male_count) male_count,
       0 female_count
FROM manufacture as m
   LEFT JOIN population as s
      ON s.region_id = m.region_id
          AND s.product_type_id = 1002
   INNER JOIN population as p
      ON p.region_id = m.region_id
          AND p.product_type_id = 1000
WHERE COALESCE(s.male_count,0) <= 500*m.manufacture_count
   AND m.manufacture_type_id = 7
UNION ALL
SELECT m.region_id,
       1000 product_type_id,
       -MIN(500*m.manufacture_count-COALESCE(s.male_count,0), p.male_count) male_count,
       0 female_count
FROM manufacture as m
   LEFT JOIN population as s
      ON s.region_id = m.region_id
          AND s.product_type_id = 1002
   INNER JOIN population as p
      ON p.region_id = m.region_id
          AND p.product_type_id = 1000
WHERE COALESCE(s.male_count,0) <= 500*m.manufacture_count
   AND m.manufacture_type_id = 7
)
INSERT INTO population (
region_id,
product_type_id,
male_count,
female_count
)
SELECT p.region_id,
       p.product_type_id,
       p.male_count,
       p.female_count    
FROM cte p
WHERE 1 = 1
ON CONFLICT(region_id,product_type_id)
DO UPDATE
SET male_count = male_count + excluded.male_count,
    female_count = female_count + excluded.female_count;
	
INSERT INTO population_history (
region_id,
product_type_id,
male_count,
female_count,
game_date
)
SELECT p.region_id,
       p.product_type_id,
       p.male_count,
       p.female_count,
       g.game_date
FROM population p
   INNER JOIN global g
       ON g.global_id = 1;