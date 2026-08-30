
WITH city_yearly AS (
    SELECT
        "City",
        "Year",
        AVG("AVG_PRICE_SQM") AS avg_price
    FROM city_metrics
    WHERE "Granularity" = 'quarterly'
      AND "Inflation_adjusted" = 1
    GROUP BY "City", "Year"
),

city_with_previous AS (
    SELECT
        "City",
        "Year",
        avg_price,
        LAG(avg_price) OVER (
            PARTITION BY "City"
            ORDER BY "Year"
        ) AS prev_year_price
    FROM city_yearly
),

city_yoy AS (
    SELECT
        "City",
        "Year",
        avg_price,
        ROUND(
            (
                (avg_price - prev_year_price)
                / NULLIF(prev_year_price, 0)
                * 100
            )::numeric,
            2
        ) AS yoy_price_growth
    FROM city_with_previous
    WHERE prev_year_price IS NOT NULL
),

national_benchmark AS (
    SELECT
        "Year",
        AVG(yoy_price_growth) AS national_avg_growth,
        STDDEV(yoy_price_growth) AS national_stddev_growth
    FROM city_yoy
    GROUP BY "Year"
),

city_zscore AS (
    SELECT
        c."City",
        c."Year",
        c.yoy_price_growth,
        n.national_avg_growth,

        ROUND(
            (
                (c.yoy_price_growth - n.national_avg_growth)
                / NULLIF(n.national_stddev_growth, 0)
            )::numeric,
            2
        ) AS price_zscore

    FROM city_yoy c
    JOIN national_benchmark n
        ON c."Year" = n."Year"
)

SELECT
    "City",
    "Year",
    yoy_price_growth,
    national_avg_growth,
    price_zscore,

    RANK() OVER (
        PARTITION BY "Year"
        ORDER BY price_zscore DESC
    ) AS pressure_rank_within_year

FROM city_zscore
WHERE "Year" >= 2020
ORDER BY "Year", pressure_rank_within_year;
