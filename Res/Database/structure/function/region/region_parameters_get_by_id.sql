SELECT r.region_id,
       "Название" header,
	   r.region_name value
FROM region as r
   INNER JOIN _params as p
       ON p.column1 = r.region_id
UNION ALL
SELECT r.region_id,
       "Финансы" header,
       CAST(ROUND(r.finance,2) AS VARCHAR)||"$" value
FROM region as r
   INNER JOIN _params as p
       ON p.column1 = r.region_id
UNION ALL
SELECT p.region_id,
       "Население" header,
       CAST(CAST(SUM(p.male_count+p.female_count) AS INT) AS VARCHAR) value
FROM population as p
   INNER JOIN _params as p
       ON p.column1 = p.region_id
GROUP BY p.region_id;