WITH cte AS MATERIALIZED (
SELECT DISTINCT vmp.manufacture_id,
       MAX(m.effectivity - IIF(m.is_deficit = 0, 0.05, 0.0),0.0) effectivity,
       vmp.is_deficit
FROM v_manufacture_production as vmp
   INNER JOIN manufacture as m
       ON vmp.manufacture_id = m.manufacture_id
           AND vmp.is_deficit != m.is_deficit
UNION ALL
SELECT m.manufacture_id,
       MIN(MAX(m.effectivity + IIF(m.is_deficit = 0, 0.01, -0.01),0.0), 1.0) effectivity,
       m.is_deficit
FROM manufacture as m
WHERE (m.is_deficit = 0 AND m.effectivity < 1.0)
    OR (m.is_deficit = 1 AND m.effectivity > 0.0)
)
UPDATE manufacture as m
SET effectivity = (
        SELECT vmp.effectivity
        FROM cte as vmp
        WHERE vmp.manufacture_id = m.manufacture_id
    ),
    is_deficit =  (
        SELECT vmp.is_deficit
        FROM cte as vmp
        WHERE vmp.manufacture_id = m.manufacture_id
    )
WHERE EXISTS (
   SELECT 1
   FROM cte as vmp
   WHERE vmp.manufacture_id = m.manufacture_id
);