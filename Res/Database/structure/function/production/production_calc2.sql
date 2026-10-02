WITH cte AS (
SELECT r.region_id, 
       c.product_type_id,
       (r.male_count+r.female_count)*c.consumption outcome,
       0.0 income
FROM population AS r
   INNER JOIN consumption AS c
       ON c.pproduct_type_id = r.product_type_id
UNION ALL
SELECT m.region_id,
       mp.product_type_id,
       0 outcome,
       mp.count*m.manufacture_count income
FROM manufacture AS m
    INNER JOIN manufacture_production mp
       ON m.manufacture_type_id = mp.manufacture_type_id
WHERE mp.count > 0
UNION ALL
SELECT m.region_id,
       mp.product_type_id,
       ABS(mp.count*m.manufacture_count) outcome,
	0 income
FROM manufacture AS m
   INNER JOIN manufacture_production mp
       ON m.manufacture_type_id = mp.manufacture_type_id
WHERE mp.count < 0
UNION ALL
SELECT t.region_id_from region_id,
       t.product_type_id,
       t.count outcome,
       0 income
FROM trading as t
UNION ALL
SELECT t.region_id_to region_id,
       t.product_type_id,
       0 outcome,
       t.count income
FROM trading as t
UNION ALL
SELECT t.region_id_from region_id,
       3 product_type_id,
       ROUND(t.count/500+0.49999999999) outcome,
       0 income
FROM trading as t
WHERE t.is_sea = true
UNION ALL
SELECT r.region_id,
       r.product_type_id,
       0 outcome,
       r.male_count + r.female_count income
FROM population AS r
UNION 
SELECT bq.region_id,
       mp.product_type_id,
       SUM(mp.count) outcome,
       0 income
FROM building_queue as bq
   INNER JOIN manufacture_price as mp
       ON bq.manufacture_type_id = mp.manufacture_type_id
GROUP BY bq.region_id,
         mp.product_type_id
)
INSERT INTO production(
region_id,
product_type_id,
price,
income_count,
outcome_count,
unit_price,
prime_cost
)
SELECT t.region_id,
       mp.product_type_id,
       MAX(
           (SUM(1.0*cte.outcome)/SUM(cte.income))*(SUM(1.0*t.price)/SUM(mp.count)),
           (SUM(1.0*t.price)/SUM(mp.count))*0.125
       ) price,
       SUM(cte.income) income_count,
       SUM(cte.outcome) outcome_count,
       MAX(
           (SUM(1.0*cte.outcome)/(SUM(cte.income)+1.0))*(SUM(1.0*t.price)/SUM(mp.count)),
           (SUM(1.0*t.price)/SUM(mp.count))*0.125
       ) unit_price,
       SUM(1.0*t.price)/SUM(mp.count) prime_cost
FROM manufacture_production as mp
    INNER JOIN (
	SELECT m.region_id,
	       mp.manufacture_type_id,
	       SUM(ABS(pdp.price*mp.count)) price
	FROM manufacture as m
	    INNER JOIN manufacture_production as mp
	        ON mp.manufacture_type_id = m.manufacture_type_id
	    LEFT JOIN production pdp
	        ON pdp.region_id = m.region_id
	            AND mp.product_type_id = pdp.product_type_id
	WHERE mp.count < 0
	GROUP BY m.region_id,
	       mp.manufacture_type_id
	HAVING COUNT(1) = COUNT(pdp.price)
) t ON t.manufacture_type_id = mp.manufacture_type_id
    INNER JOIN cte
        ON cte.region_id = t.region_id
            AND cte.product_type_id = mp.product_type_id
WHERE mp.count > 0
GROUP BY t.region_id,
         mp.product_type_id
UNION
SELECT cte.region_id,
       cte.product_type_id,
       MAX(
           (SUM(1.0*cte.outcome)/SUM(cte.income))*1.0,
           1.0*0.125
       ) price,
       SUM(cte.income) income_count,
       SUM(cte.outcome) outcome_count,
       MAX(
           (SUM(1.0*cte.outcome)/(SUM(cte.income)+1))*1.0,
           1.0*0.125
       ) unit_price,
       1.0 prime_cost
FROM cte
WHERE cte.product_type_id = 1000
GROUP BY cte.region_id,
         cte.product_type_id
ON CONFLICT(region_id,product_type_id)
DO UPDATE
SET price = excluded.price,
    income_count = excluded.income_count,
    outcome_count = excluded.outcome_count,
    unit_price = excluded.unit_price,
    prime_cost = excluded.prime_cost;


INSERT INTO production_history (
region_id,
product_type_id,
price,
income_count,
outcome_count,
unit_price,
game_date,
prime_cost
)
SELECT p.region_id,
       p.product_type_id,
       p.price,
       p.income_count,
       p.outcome_count,
       p.unit_price,
       g.game_date,
       p.prime_cost
FROM production as p
   INNER JOIN global as g
       ON g.global_id = 1;