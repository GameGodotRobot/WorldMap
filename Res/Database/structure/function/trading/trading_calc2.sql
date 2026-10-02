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