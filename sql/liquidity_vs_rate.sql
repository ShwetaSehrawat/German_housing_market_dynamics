with tom_yearly as (
select "Year", round(avg("TOM_4q")::numeric,1) as avg_tom_days from tom
group by "Year"),
rate_yearly as (select cast(left("Date",4) as integer) as year, round(avg("Interest_rate")::numeric,2) as avg_interest_rate 
from bb_rate_all 
group by cast(left("Date",4) as integer)
)
select t."Year", t.avg_tom_days, r.avg_interest_rate from tom_yearly as t
join rate_yearly as r on t."Year" = r.year 
order by t."Year";