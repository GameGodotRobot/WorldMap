SELECT r.country_id,
       "Название" header,
	   r.country_name value
FROM country as r
   INNER JOIN _params as p
       ON p.column1 = r.country_id
UNION ALL
SELECT r.country_id,
       "Финансы" header,
       CAST(ROUND(r.finance,2) AS VARCHAR)||"$" value
FROM country as r
   INNER JOIN _params as p
       ON p.column1 = r.country_id
UNION ALL
SELECT r.country_id,
       "Население" header,
       CAST(CAST(SUM(p.male_count+p.female_count) AS INT) AS VARCHAR) value
FROM population as p
   INNER JOIN region as r
       ON r.region_id = p.region_id
   INNER JOIN _params as p
       ON p.column1 = r.country_id
GROUP BY r.country_id;