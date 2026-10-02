SELECT r.country_id,
       cte.product_type_id,
	   pt.product_type_name,
       SUM(cte.price)/COUNT(1) price,
       SUM(cte.income_count) income_count,
       SUM(cte.outcome_count) outcome_count,
	   SUM(cte.unit_price)/COUNT(1) unit_price
FROM production as cte
   INNER JOIN product_type as pt
	     ON cte.product_type_id = pt.product_type_id
   INNER JOIN region as r
       ON cte.region_id = r.region_id
   INNER JOIN _params as p
       ON p.column1 = r.country_id
GROUP BY r.country_id,
         cte.product_type_id,
         pt.product_type_name;