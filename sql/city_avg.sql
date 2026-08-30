select "City", round(avg("AVG_PRICE_SQM")::NUMERIC,2) as average_price, count(*) as num_quarters
from city_metrics
where "Granularity"='quarterly' and "Inflation_adjusted"=1
group by "City"
order by average_price desc;