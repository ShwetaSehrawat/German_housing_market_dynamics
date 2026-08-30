with first_last as (
select "City", first_value("Rent_Index") over(Partition by "City" 
order by "Year", "Quarter") as first_rent,
last_value ("Rent_Index") over (partition by "City"
order by "Year", "Quarter" rows between unbounded preceding and unbounded following) as last_rent,
first_value("Sales_Index") over (Partition by "City"
order by "Year", "Quarter") as first_sales,
last_value ("Sales_Index") over (partition by "City"
order by "Year", "Quarter" rows between unbounded preceding and unbounded following) as last_sales  
from rents_sales
where "Granularity" = 'quarterly' and "Inflation_adjusted"=1),
growth as ( select distinct"City", round(((last_rent - first_rent)/first_rent*100)::numeric, 1) as rent_growth_pct,
round(((last_sales - first_sales)/first_sales*100)::numeric,1 ) as sales_growth_pct
from first_last)
select "City", rent_growth_pct, sales_growth_pct, round((sales_growth_pct - rent_growth_pct)::numeric,1) as gap, 
rank() over (order by (sales_growth_pct - rent_growth_pct) desc) as gap_rank 
from growth 
order by gap_rank;