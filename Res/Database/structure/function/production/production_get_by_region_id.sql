SELECT cte.region_id,
       cte.product_type_id,
	   pt.product_type_name,
       cte.price,
       cte.income_count,
       cte.outcome_count,
	   cte.unit_price
FROM production as cte
     INNER JOIN product_type as pt
	     ON cte.product_type_id = pt.product_type_id
     INNER JOIN _params as p
	     ON p.column1=cte.region_id;