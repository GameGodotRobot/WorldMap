UPDATE manufacture as m
SET manufacture_count = manufacture_count + 
(
	SELECT COUNT(1)
	FROM building_queue as bq
	    INNER JOIN global as g
	       ON g.game_date > bq.end_date
	WHERE bq.region_id = m.region_id
	   AND bq.manufacture_type_id = m.manufacture_type_id
)
WHERE EXISTS(
SELECT 1
FROM building_queue bq
	INNER JOIN global as g
	    ON g.game_date > bq.end_date
WHERE bq.manufacture_type_id = m.manufacture_type_id
AND bq.region_id = m.region_id
);

DELETE
FROM building_queue as bq
WHERE bq.end_date > (
                        SELECT g.game_date
                        FROM global as g
                        WHERE g.global_id = 1
                    );

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

	   
INSERT INTO production(
region_id,
product_type_id,
price,
income_count,
outcome_count,
unit_price,
prime_cost,
price_tax
)
SELECT a.region_id,
       a.product_type_id,
       n.price_growth_coeff*a.price + MAX(n.price_growth_coeff*a.price - a.price,0.0)*r.price_tax price,
       n.income income_count,
       n.outcome outcome_count,
       n.price_growth_coeff_with_one*a.price + MAX(n.price_growth_coeff_with_one*a.price - a.price,0.0)*r.price_tax unit_price,
       a.price prime_cost,
       MAX(n.price_growth_coeff*a.price - a.price,0.0)*r.price_tax price_tax
FROM avg_cost_of_products_with_const as a
    INNER JOIN need_for_products as n
        ON n.region_id = a.region_id
            AND n.product_type_id = a.product_type_id
   INNER JOIN region r
       ON r.region_id = n.region_id
ON CONFLICT(region_id,product_type_id)
DO UPDATE
SET price = excluded.price,
    income_count = excluded.income_count,
    outcome_count = excluded.outcome_count,
    unit_price = excluded.unit_price,
    prime_cost = excluded.prime_cost,
    price_tax = excluded.price_tax;


WITH balance AS (
SELECT cte.region_id,
       cte.product_type_id,
       cte.price price,
       CAST(cte.income_count AS INT) income_count,
       cte.outcome_count,
       cte.price - cte.unit_price unit_price, -- на сколько единица товара снижает цену
       CAST(COALESCE(shp.manufacture_count*100,0) AS INT) ship_count,
       t.export_tax export_tax,
       t.import_tax import_tax,
       t.country_id
FROM production as cte
    LEFT JOIN manufacture as shp
          ON shp.region_id = cte.region_id
               AND manufacture_type_id = 5
    INNER JOIN region as r
        ON r.region_id = cte.region_id
    INNER JOIN country_ie_tax as t
        ON t.country_id = r.country_id
             AND t.product_type_id = cte.product_type_id
),
cte AS (
SELECT b1.region_id region_from,
       b2.region_id region_to,
       b1.product_type_id,
       b1.income_count trade_count,
       CAST(0.5*(b2.price-b1.price)/b2.unit_price AS INT) trade_needs,
       0 max_ship_count,
       0 ship_needs,
       0 ship_needs_total,
       0.5*(b2.price + b1.price) price_new,
       CASE WHEN b1.country_id != b2.country_id
            THEN 0.5*(b2.price+b1.price)*(1.0/(b2.import_tax) - 1.0/(b1.export_tax*b2.import_tax))
            ELSE 0
       END export_tax,
       CASE WHEN b1.country_id != b2.country_id
            THEN 0.5*(b2.price+b1.price)*(1.0 - 1.0/(b2.import_tax)) 
            ELSE 0
       END import_tax,
       b2.price price_current
FROM balance AS b1
    INNER JOIN region_neighbour_connect AS rnc
          ON rnc.region_id = b1.region_id
    INNER JOIN balance as b2
          ON rnc.neighbour_region_id = b2.region_id
               AND b1.product_type_id = b2.product_type_id
WHERE rnc.land_distance > 0
    AND CAST((b2.price - b1.price)/b2.unit_price AS INT) > 0
    AND ( b1.country_id = b2.country_id
        OR b2.price 
           - 0.5*(b2.price + b1.price)
           - 0.5*(b2.price+b1.price)*(1.0 - 1.0/(b2.import_tax))
           - 0.5*(b2.price+b1.price)*(1.0/(b2.import_tax) - 1.0/(b1.export_tax*b2.import_tax))
           > 0 )
UNION ALL
SELECT b1.region_id region_from,
       b2.region_id region_to,
       b1.product_type_id,
       MIN(b1.income_count, b1.ship_count*500) trade_count,
       CAST(0.5*(b2.price - b1.price)/b2.unit_price AS INT) trade_needs,
       b1.ship_count max_ship_count,
       MIN(ROUND(0.002*CAST(0.5*(b2.price - b1.price)/b2.unit_price AS INT)+0.49999999), b1.ship_count) ship_needs,
       SUM(MIN(ROUND(0.002*CAST(0.5*(b2.price - b1.price)/b2.unit_price AS INT)+0.49999999), b1.ship_count)) OVER (
                                                 PARTITION BY b1.region_id
                                                 ORDER BY b2.price - b1.price DESC,
                                                          b2.region_id
                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

       ) ship_needs_total,
       0.5*(b2.price + b1.price) price_new,
       CASE WHEN b1.country_id != b2.country_id
            THEN 0.5*(b2.price+b1.price)*(1.0/(b2.import_tax) - 1.0/(b1.export_tax*b2.import_tax))
            ELSE 0
       END export_tax,
       CASE WHEN b1.country_id != b2.country_id
            THEN 0.5*(b2.price+b1.price)*(1.0 - 1.0/(b2.import_tax)) 
            ELSE 0
       END import_tax,
       b2.price price_current
FROM balance AS b1
    INNER JOIN region_neighbour_connect AS rnc
          ON rnc.region_id = b1.region_id
    INNER JOIN balance as b2
          ON rnc.neighbour_region_id = b2.region_id
               AND b1.product_type_id = b2.product_type_id
WHERE b1.ship_count > 0
    AND rnc.land_distance = 0
    AND CAST((b2.price - b1.price)/b2.unit_price AS INT) > 0
    AND ( b1.country_id = b2.country_id
        OR b2.price 
           - 0.5*(b2.price + b1.price)
           - 0.5*(b2.price+b1.price)*(1.0 - 1.0/(b2.import_tax))
           - 0.5*(b2.price+b1.price)*(1.0/(b2.import_tax) - 1.0/(b1.export_tax*b2.import_tax))
           > 0 )
),
ship_calc AS (
SELECT cte.region_from,
       cte.region_to,
       cte.product_type_id,
       cte.trade_count,
       cte.price_new,
       CASE WHEN cte.ship_needs = 0
            THEN cte.trade_needs
            ELSE MIN(cte.trade_needs, 
                     500*CASE WHEN cte.max_ship_count - cte.ship_needs_total >= 0
                          THEN cte.ship_needs
                          ELSE cte.ship_needs-cte.max_ship_count+cte.ship_needs_total
                     END)
       END trade_needs,
       CASE WHEN cte.max_ship_count - cte.ship_needs_total >= 0
            THEN cte.ship_needs
            ELSE cte.ship_needs-cte.max_ship_count+cte.ship_needs_total
       END ship_needs,
       cte.price_current,
       cte.import_tax,
       cte.export_tax
FROM cte
WHERE (cte.ship_needs_total = 0
    OR cte.max_ship_count - cte.ship_needs_total > -1.0*cte.ship_needs)
),
last_total AS (
SELECT sc.region_from,
       sc.region_to,
       sc.product_type_id,
       sc.price_new,
       sc.trade_count,
       sc.trade_needs,
       sc.ship_needs,
       sc.price_current,
       sc.import_tax,
       sc.export_tax,
       SUM( sc.trade_needs ) OVER (PARTITION BY sc.region_to,
                                                sc.product_type_id
                                   ORDER BY sc.price_new,
                                            sc.region_to
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

       ) trade_needs_total_between_region,
       SUM( sc.trade_needs ) OVER (PARTITION BY sc.region_from,
                                                sc.product_type_id
                                   ORDER BY sc.price_new,
                                            sc.region_to
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

       ) trade_needs_total_in_region
FROM ship_calc as sc
)
INSERT INTO trading (
    region_id_from,
    region_id_to,
    product_type_id,
    price,
    count,
    ship_needs,
    import_tax,
    export_tax,
    net_profit
)
SELECT sc.region_from,
       sc.region_to,
       sc.product_type_id,
       sc.price_new,
       CASE WHEN sc.trade_count - sc.trade_needs_total_in_region > 0
            THEN sc.trade_needs
            ELSE sc.trade_needs - sc.trade_count + sc.trade_needs_total_in_region
       END trade_needs,
       sc.ship_needs,
       sc.import_tax,
       sc.export_tax,
       sc.price_current-sc.price_new -sc.import_tax-sc.export_tax net_profit
FROM last_total sc
WHERE sc.trade_count - sc.trade_needs_total_in_region > -1.0*sc.trade_needs
   AND sc.trade_needs >=  sc.trade_needs_total_between_region
ON CONFLICT(region_id_from, region_id_to, product_type_id)
DO UPDATE
SET price = excluded.price,
    count = count + excluded.count,
    ship_needs = excluded.ship_needs,
    import_tax = excluded.import_tax,
    export_tax = excluded.export_tax,
    net_profit = excluded.net_profit;


WITH cte AS (
SELECT t1.region_id_from,
       t1.region_id_to,
       t1.product_type_id,
       t1.price price,
       t1.count - COALESCE(t2.count,0) count,
       t1.ship_needs,
       t1.import_tax,
       t1.export_tax,
       t1.net_profit
FROM trading t1
   LEFT JOIN trading t2
        ON t1.region_id_from = t2.region_id_to
             AND t2.region_id_from = t1.region_id_to
             AND t1.product_type_id = t2.product_type_id
WHERE t1.count > t2.count
   OR t2.count IS NULL
UNION ALL
SELECT t2.region_id_from,
       t2.region_id_to,
       t2.product_type_id,
       t2.price,
       t2.count - t1.count count,
       t2.ship_needs,
       t2.import_tax,
       t2.export_tax,
       t2.net_profit
FROM trading t1
   INNER JOIN trading t2
        ON t1.region_id_from = t2.region_id_to
             AND t2.region_id_from = t1.region_id_to
             AND t1.product_type_id = t2.product_type_id
WHERE t1.count < t2.count
),
cte2 AS (
SELECT t2.region_id_from,
       t2.region_id_to,
       t2.product_type_id,
       t2.price,
       0 count,
       t2.ship_needs,
       t2.import_tax,
       t2.export_tax,
       t2.net_profit
FROM trading t2
   LEFT JOIN cte
        ON cte.region_id_from = t2.region_id_to
             AND cte.region_id_from = t2.region_id_to
             AND cte.product_type_id = t2.product_type_id
WHERE cte.region_id_from IS NULL
UNION ALL
SELECT cte.region_id_from,
       cte.region_id_to,
       cte.product_type_id,
       cte.price,
       cte.count,
       cte.ship_needs,
       cte.import_tax,
       cte.export_tax,
       cte.net_profit
FROM cte
)
INSERT INTO trading (
    region_id_from,
    region_id_to,
    product_type_id,
    price,
    count,
    ship_needs,
    import_tax,
    export_tax,
    net_profit
)
SELECT t.region_id_from,
       t.region_id_to,
       t.product_type_id,
       t.price,
       t.count,
       t.ship_needs,
       t.import_tax,
       t.export_tax,
       t.net_profit
FROM cte2 AS t
WHERE 1 = 1
ON CONFLICT(region_id_from, region_id_to, product_type_id)
DO UPDATE
SET price = excluded.price,
    count = excluded.count,
    ship_needs = excluded.ship_needs,
    import_tax = excluded.import_tax,
    export_tax = excluded.export_tax,
    net_profit = excluded.net_profit;

DELETE
FROM trading
WHERE count = 0;
	

INSERT INTO production(
region_id,
product_type_id,
price,
income_count,
outcome_count,
unit_price,
prime_cost,
price_tax
)
SELECT a.region_id,
       a.product_type_id,
       n.price_growth_coeff*a.price + MAX(n.price_growth_coeff*a.price - a.price,0.0)*r.price_tax price,
       n.income income_count,
       n.outcome outcome_count,
       n.price_growth_coeff_with_one*a.price + MAX(n.price_growth_coeff_with_one*a.price - a.price,0.0)*r.price_tax unit_price,
       a.price prime_cost,
       MAX(n.price_growth_coeff*a.price - a.price,0.0)*r.price_tax price_tax
FROM avg_cost_of_products_with_const as a
    INNER JOIN need_for_products as n
        ON n.region_id = a.region_id
            AND n.product_type_id = a.product_type_id
   INNER JOIN region r
       ON r.region_id = n.region_id
ON CONFLICT(region_id,product_type_id)
DO UPDATE
SET price = excluded.price,
    income_count = excluded.income_count,
    outcome_count = excluded.outcome_count,
    unit_price = excluded.unit_price,
    prime_cost = excluded.prime_cost,
    price_tax = excluded.price_tax;
	
	
UPDATE manufacture as m
SET finance = finance + COALESCE((
SELECT mfp.finance
FROM manufacture_finance_period mfp
WHERE mfp.region_id = m.region_id
   AND mfp.manufacture_type_id = m.manufacture_type_id
),0);

UPDATE region as r
SET finance = finance + COALESCE((
   SELECT SUM(p.price_tax*MIN(p.income_count,p.outcome_count))
   FROM production p
   WHERE p.region_id = r.region_id
       AND p.price_tax > 0
),0);

UPDATE country as c
SET finance = finance + COALESCE((
   SELECT SUM(
                CASE WHEN r1.country_id = c.country_id
                     THEN t.export_tax
                     ELSE t.import_tax
                END * t.count
             )
   FROM trading t
       INNER JOIN region as r1
           ON t.region_id_from = r1.region_id
       INNER JOIN region as r2
           ON t.region_id_from = r2.region_id
   WHERE r1.country_id = c.country_id
       OR r2.country_id = c.country_id
),0);