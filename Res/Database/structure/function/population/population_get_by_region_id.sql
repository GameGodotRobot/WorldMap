SELECT p.region_id,
       p.product_type_id,
       p.male_count,
       p.female_count
FROM population as p
   INNER JOIN _params as p2
      ON p.region_id = p2.column1;