with city_avg as (
select "City", round(avg("AVG_PRICE_SQM")::NUMERIC,2) as average_price
from city_metrics
where "Granularity"='quarterly' and "Inflation_adjusted"=1
group by "City"
)
select "City", average_price, rank() over (order by average_price desc) as price_rank from city_avg 
order by price_rank;