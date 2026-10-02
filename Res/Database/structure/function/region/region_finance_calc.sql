UPDATE region as r
SET finance = finance + COALESCE((
   SELECT SUM(p.price_tax*MIN(p.income_count,p.outcome_count))
   FROM production p
   WHERE p.region_id = r.region_id
       AND p.price_tax > 0
),0);