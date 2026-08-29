# German Housing Market Analytics

A data analytics project tracking housing prices, rents, market liquidity, and financing conditions across German cities from 2012 to 2026. Built with Python, Pandas, PostgreSQL, SQL, and Power BI.

## What this project does

Nine raw datasets from three German institutional sources (GREIX, Bundesbank) get cleaned, integrated, and analyzed to answer a central question: how have housing prices, rents, and market liquidity evolved across major German cities, and how do these trends relate to national financing conditions.

This is not a "housing crisis" project. The available data supports price, rent, and liquidity trends well, but there's no income or population data included, so affordability in the strict sense can't be measured as a trend. The project is scoped around what the data can actually prove, not around a bigger claim it can't back up.

## Data sources

Primary datasets, the ones the analysis is actually built on:
- City_metrics_public.xlsx (GREIX): price index and price per square meter, 38 cities, 2012 to 2026, mixing monthly, quarterly, and annual granularity
- City_Metrics_rents_sales.xlsx (GREIX): rent index and sales price index side by side, 23 cities, 2012 to 2025
- ETW_EFH_final_TOM_quarterly.xlsx (GREIX): time on market and share closed within two weeks, split by property type (houses vs apartments), 25 cities
- Three Bundesbank series: national mortgage lending volume and effective interest rates, monthly, 2003 to 2026

Secondary datasets, not used in the core analysis:
- Regionale_Spardauer_greix.xlsx: a district-level affordability snapshot with no time axis, useful as a standalone exhibit but not joinable to the time series data
- Destatis construction statistics: national and state-level, short time window, kept out of the core model

## Data cleaning

Each raw file was loaded, inspected, and cleaned in its own notebook under notebooks/, with every fix verified against the actual output rather than assumed. A few things came up worth mentioning specifically:

Mixed time granularity. City_metrics_public.xlsx has monthly, quarterly, and annual rows sitting in the same table with no label distinguishing them. A Granularity column was built to make this explicit, so any aggregation can filter to one time resolution instead of silently blending them together.

A national row disguised as a city. All three GREIX city-level files include a "Greix" (or "GREIX") row representing the national composite average, mixed into the same column as real cities. This got mapped to a clear constant and split into its own table, so it never gets counted as an extra city in a comparison.

Inconsistent city names across files. The same city shows up spelled differently depending on the file: Frankfurt am Main appears as "FFM" in one file, Rhein-Erft-Kreis appears as "REK," and Mettmann shows up three different ways across three files. A shared mapping module (src/city_mapping.py) standardizes every known spelling before any file gets joined to another.

Hidden footnote rows in the Bundesbank files. All three Bundesbank CSVs have a trailing row with no date, just a comment about a 2010 methodology change, sitting where a real observation should be. This one row was silently breaking the numeric type of the entire column until it got identified and removed.

Verified, not assumed. Every unusual number got traced back to its source before being trusted. Missing values in the TOM columns were confirmed to be a mechanical artifact of a 4-quarter rolling average needing history before it can compute anything, not a data quality problem. Extreme price values were traced to specific cities and years and checked against what's actually known about the German housing market.

## Key findings
Berlin grew fastest, not München. Ranking all 37 cities by real (inflation-adjusted) price growth from 2012 to 2026, Berlin comes out on top at 55.5 percent, despite having the lowest absolute price level among the five major cities. München, the most expensive city by level, grew more slowly at 36.1 percent. Price level and growth rate are different questions, and looking only at level would have missed this.

Chemnitz is the only city with negative growth. Down 5.4 percent over the full period, the only one of 37 cities to lose value in real terms. Its quarterly history shows a genuinely flat market from 2012 through 2021, followed by a real, sustained decline starting in 2022, consistent with Chemnitz's position as a smaller eastern German city.

Sale prices outpaced rent everywhere, but by wildly different amounts. Every city in the dataset shows sales growing faster than rent. Rhein-Erft-Kreis shows the widest gap, sales up 124.3 percent against rent up just 19.0 percent, a 105.3 percentage point divergence, verified against its full quarterly history to confirm it's a real, sustained trend rather than a data artifact.

Market liquidity tracks interest rates with roughly a one year lag. Time on market and mortgage interest rates fall together from 2012 to 2021, both hitting their lowest point in 2021. When rates start rising sharply in 2022, time on market doesn't respond immediately, the bigger increase shows up in 2023 and peaks in 2024. The market appears to absorb financing shocks with a delay rather than reacting instantly.

Nominal growth roughly doubles real growth, but the ranking barely changes. Comparing nominal against inflation-adjusted growth across all 37 cities, only two cities swap rank position. Inflation affected nearly every city by a similar amount, roughly 44 to 57 percentage points of nominal growth, which is why the story changes in scale but not in which cities are actually leading or lagging.

## SQL analysis

Nine cleaned tables are loaded into a PostgreSQL database (shweta_housing). Queries under sql/ use CTEs, window functions (RANK(), FIRST_VALUE, LAST_VALUE, LAG()), and Z-score standardization to formalize the EDA findings directly in SQL, independent of the pandas analysis, and confirm they hold up.

- 01_city_price_growth.sql: ranks all cities by average inflation-adjusted price
- 02_rent_price_divergence.sql: calculates the rent-versus-sales growth gap per city
- 03_liquidity_vs_financing.sql: joins yearly market liquidity against yearly interest rates
- 04_composite_pressure_score.sql: combines year-over-year price growth with a Z-score against the national average to rank cities by relative housing market pressure, per year

## Project structure

data/raw/        original files, untouched
data/clean/       cleaned CSVs, output of the cleaning notebooks
notebooks/        cleaning, EDA, and PostgreSQL loading notebooks, numbered in run order
src/              shared code, including the city name mapping module
sql/              analytical SQL queries
powerbi/          Power BI dashboard file## Limitations

The GREIX city sample (20 to 38 cities depending on the file) is a curated set of mostly larger and mid-size cities, not a complete national panel, so findings describe these tracked markets specifically, not all of Germany. The exact base period behind the price and rent indices isn't stated in the source files. National-level financing data can only be linked to city-level liquidity through the "Greix" national aggregate row, which is an approximation rather than a true weighted average of the specific tracked cities. No income or population data is included, so affordability as a trend over time isn't something this project can measure, only price, rent, and liquidity trends.