INSERT INTO building_queue (
region_id,
manufacture_type_id,
end_date
)
SELECT m.region_id,
       m.manufacture_type_id,
       DATE(g.game_date, "+"||CAST(mt.building_time AS VARCHAR)||" days") end_date
FROM manufacture as m
   INNER JOIN _params as pp
       ON pp.column2 = m.manufacture_type_id
           AND pp.column1 = m.region_id
   INNER JOIN manufacture_type as mt
       ON mt.manufacture_type_id = m.manufacture_type_id
   INNER JOIN global as g
       ON g.global_id = 1
   INNER JOIN manufacture_price as mp
       ON m.manufacture_type_id = mp.manufacture_type_id
   INNER JOIN production as p
       ON p.product_type_id = mp.product_type_id
          AND p.region_id = m.region_id
   INNER JOIN region as r
       ON r.region_id = m.region_id
GROUP BY m.region_id,
         m.manufacture_type_id,
         DATE(g.game_date, "+"||CAST(m.manufacture_count AS VARCHAR)||"days"),
         r.finance
HAVING SUM(p.price*mp.count*mt.building_time) < r.finance;

WITH cte AS (
   SELECT p.region_id,
          SUM(mp.count*p.price*mt.building_time) finance
   FROM manufacture_price as mp
      INNER JOIN manufacture_type as mt
          ON mp.manufacture_type_id = mt.manufacture_type_id
      INNER JOIN _params as pp
	      ON pp.column2 = mp.manufacture_type_id
      INNER JOIN production as p
          ON p.product_type_id = mp.product_type_id
              AND pp.column1 = p.region_id
   WHERE r.region_id = p.region_id
   GROUP BY p.region_id
)
UPDATE region as r
SET finance = finance - (
   SELECT finance
   FROM cte
   WHERE r.region_id = cte.region_id
)
WHERE r.finance > (
   SELECT finance
   FROM cte
   WHERE r.region_id = cte.region_id
);
