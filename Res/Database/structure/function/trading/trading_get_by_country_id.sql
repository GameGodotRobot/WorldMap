SELECT t.region_id_from,
       t.region_id_to,
       t.product_type_id,
       t.price,
       t.count
FROM trading AS t
    INNER JOIN region as r
	    ON t.region_id_from = r.region_id
            OR t.region_id_to = r.region_id
    INNER JOIN _params AS p
	    ON p.column1 = r.country_id
ORDER BY t.region_id_from,
         t.region_id_to;