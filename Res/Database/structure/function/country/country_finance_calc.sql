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