SELECT bq.building_queue_id,
       bq.region_id,
       bq.manufacture_type_id,
       bq.end_date
FROM building_queue as bq
   INNER JOIN _params as p
        ON bq.region_id = p.column1
ORDER BY bq.manufacture_type_id,
         bq.building_queue_id;