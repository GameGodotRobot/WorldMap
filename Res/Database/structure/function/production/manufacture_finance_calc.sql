UPDATE manufacture as m
SET finance = finance + COALESCE((
SELECT mfp.finance
FROM manufacture_finance_period mfp
WHERE mfp.region_id = m.region_id
   AND mfp.manufacture_type_id = m.manufacture_type_id
),0);

