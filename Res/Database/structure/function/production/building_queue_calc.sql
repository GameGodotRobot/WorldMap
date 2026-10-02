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