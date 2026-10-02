INSERT INTO production(
region_id,
product_type_id,
price,
income_count,
outcome_count,
unit_price,
prime_cost,
price_tax
)
SELECT a.region_id,
       a.product_type_id,
       n.price_growth_coeff*a.price + MAX(n.price_growth_coeff*a.price - a.price,0.0)*r.price_tax price,
       n.income income_count,
       n.outcome outcome_count,
       n.price_growth_coeff_with_one*a.price + MAX(n.price_growth_coeff_with_one*a.price - a.price,0.0)*r.price_tax unit_price,
       a.price prime_cost,
       MAX(n.price_growth_coeff*a.price - a.price,0.0)*r.price_tax price_tax
FROM avg_cost_of_products_with_const as a
    INNER JOIN need_for_products as n
        ON n.region_id = a.region_id
            AND n.product_type_id = a.product_type_id
   INNER JOIN region r
       ON r.region_id = n.region_id
ON CONFLICT(region_id,product_type_id)
DO UPDATE
SET price = excluded.price,
    income_count = excluded.income_count,
    outcome_count = excluded.outcome_count,
    unit_price = excluded.unit_price,
    prime_cost = excluded.prime_cost,
    price_tax = excluded.price_tax;