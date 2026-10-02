SELECT m.manufacture_type_id,
       m.product_type_id,
       m.count
FROM manufacture_price as m
   INNER JOIN _params as p
       ON p.column1 = m.manufacture_type_id;