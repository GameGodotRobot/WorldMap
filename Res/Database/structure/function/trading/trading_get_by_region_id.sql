SELECT t.region_id_from,
       t.region_id_to,
       t.product_type_id,
       t.price,
       t.count
FROM trading AS t
    INNER JOIN _params AS p
	    ON p.column1 = t.region_id_from
		    OR p.column1 = t.region_id_to
ORDER BY t.region_id_from,
         t.region_id_to;