# German Housing Market Analytics

A data analytics project tracking housing prices, rents, market liquidity, and financing conditions across German cities from 2012 to 2026. Built with Python, Pandas, PostgreSQL, SQL, and Power BI.

## What this project does

Nine raw datasets from three German institutional sources (GREIX, Bundesbank) get cleaned, integrated, and analyzed to answer a central question: how have housing prices, rents, and market liquidity evolved across major German cities, and how do these trends relate to national financing conditions.

This is not a "housing crisis" project. The available data supports price, rent, and liquidity trends well, but there's no income or population data included, so affordability in the strict sense can't be measured as a trend. The project is scoped around what the data can actually prove, not around a bigger claim it can't back up.

## Data sources

**Primary datasets**, the ones the analysis is actually built on:
- City_metrics_public.xlsx (GREIX): price index and price per square meter, 38 cities, 2012 to 2026, mixing monthly, quarterly, and annual granularity
- City_Metrics_rents_sales.xlsx (GREIX): rent index and sales price index side by side, 23 cities, 2012 to 2025
- ETW_EFH_final_TOM_quarterly.xlsx (GREIX): time on market and share closed within two weeks, split by property type (houses vs apartments), 25 cities
- Three Bundesbank series: national mortgage lending volume and effective interest rates, monthly, 2003 to 2026

**Secondary datasets**, not used in the core analysis:
- Regionale_Spardauer_greix.xlsx: a district-level affordability snapshot with no time axis, useful as a standalone exhibit but not joinable to the time series data
- Destatis construction statistics: national and state-level, short time window, kept out of the core model

## Data cleaning

Each raw file was loaded, inspected, and cleaned in its own notebook under `notebooks/`, with every fix verified against the actual output rather than assumed. A few things came up worth mentioning specifically:

**Mixed time granularity.** City_metrics_public.xlsx has monthly, quarterly, and annual rows sitting in the same table with no label distinguishing them. A `Granularity` column was built to make this explicit, so any aggregation can filter to one time resolution instead of silently blending them together.

**A national row disguised as a city.** All three GREIX city-level files include a "Greix" (or "GREIX") row representing the national composite average, mixed into the same column as real cities. This got mapped to a clear constant and split into its own table, so it never gets counted as an extra city in a comparison.

**Inconsistent city names across files.** The same city shows up spelled differently depending on the file: Frankfurt am Main appears as "FFM" in one file, Rhein-Erft-Kreis appears as "REK," and Mettmann shows up three different ways across three files. A shared mapping module (`src/city_mapping.py`) standardizes every known spelling before any file gets joined to another.

**Hidden footnote rows in the Bundesbank files.** All three Bundesbank CSVs have a trailing row with no date, just a comment about a 2010 methodology change, sitting where a real observation should be. This one row was silently breaking the numeric type of the entire column until it got identified and removed.

**Verified, not assumed.** Every unusual number got traced back to its source before being trusted. Missing values in the TOM columns were confirmed to be a mechanical artifact of a 4-quarter rolling average needing history before it can compute anything, not a data quality problem. Extreme price values were traced to specific cities and years and checked against what's actually known about the German housing market.

## Key findings

**Berlin grew fastest, not München.** Ranking all 37 cities by real (inflation-adjusted) price growth from 2012 to 2026, Berlin comes out on top at 55.5 percent, despite having the lowest absolute price level among the five major cities. München, the most expensive city by level, grew more slowly at 36.1 percent. Price level and growth rate are different questions, and looking only at level would have missed this.

**Chemnitz is the only city with negative growth.** Down 5.4 percent over the full period, the only one of 37 cities to lose value in real terms. Its quarterly history shows a genuinely flat market from 2012 through 2021, followed by a real, sustained decline starting in 2022 that continues through the most recent data.

This appears to be specific to Chemnitz rather than a regional pattern. Chemnitz is in eastern Germany, but the other eastern German cities in this dataset did not decline over the same period, Leipzig grew 46.6 percent, Potsdam 39.3 percent, Dresden 21.4 percent, and Erfurt 19.5 percent. Whatever is driving Chemnitz's decline, it isn't shared broadly across the region, and the cause hasn't been identified from this dataset alone.

**Sale prices outpaced rent everywhere, but by wildly different amounts.** Every city in the dataset shows sales growing faster than rent. Rhein-Erft-Kreis shows the widest gap, sales up 124.3 percent against rent up just 19.0 percent, a 105.3 percentage point divergence, verified against its full quarterly history to confirm it's a real, sustained trend rather than a data artifact.

**Market liquidity tracks interest rates with roughly a one year lag.** Time on market and mortgage interest rates fall together from 2012 to 2021, both hitting their lowest point in 2021. When rates start rising sharply in 2022, time on market doesn't respond immediately, the bigger increase shows up in 2023 and peaks in 2024. Correlating time on market against the interest rate at different lags confirms this: the correlation is 0.67 comparing them in the same year, rises to 0.90 comparing time on market against the interest rate from one year earlier, and falls back to 0.65 at a two year lag. The one year lag fits the data meaningfully better than either the same-year or two-year comparison, supporting the idea that the market absorbs financing shocks with a delay rather than reacting to them instantly.

**Nominal growth roughly doubles real growth, but the ranking barely changes.** Comparing nominal against inflation-adjusted growth across all 37 cities, only two cities swap rank position. Inflation affected nearly every city by a similar amount, roughly 44 to 57 percentage points of nominal growth, which is why the story changes in scale but not in which cities are actually leading or lagging.

## Recommendations

**For anyone evaluating rental yield across cities, the rent-versus-price gap is the most actionable signal here.** Rhein-Erft-Kreis shows the widest gap in the dataset, sale prices up 124.3 percent against rent up just 19.0 percent since 2012. A gap this size means buying there is increasingly priced for capital appreciation rather than rental income, current rents don't come close to justifying the growth in purchase price. Cities with a narrower gap, Duisburg at 20.8 points, Wiesbaden and Erfurt in the mid-30s, look more balanced on this specific metric.

**Berlin's headline growth number deserves a closer look before treating it as steady momentum.** Berlin leads all 37 cities in cumulative real growth since 2012, but a year-over-year Z-score breakdown shows its 2026 growth was actually negative, 3.57 percent below the prior year and well under the national average that year. A strong 14-year total can still contain a recent slowdown, worth checking the recent trend specifically rather than relying on the full-period figure alone.

**Market liquidity does not appear to react to rate changes immediately.** Time on market kept falling through 2022, the same year interest rates jumped sharply, and only showed its main slowdown the following year. Anyone timing a purchase or lending decision around a rate move should not expect an instant shift in how fast the market moves. This pattern is drawn from 15 annual observations and has not yet been tested with a formal lag correlation, it should be read as a pattern worth watching, not a confirmed rule.

**This project does not make affordability claims, and neither should anyone using it.** Without income or population data, there's no way to say whether housing has become harder to afford relative to what people earn, only that prices, rents, and sale activity have moved the way described above.

## Recommendations

For an investor or analyst evaluating rental yield across German cities, the widening gap between rent and sale price growth is the single most actionable signal in this dataset. Rhein-Erft-Kreis shows the widest gap in the project, sale prices up 124.3 percent against rent up just 19.0 percent since 2012. A gap this size means buying there is increasingly priced for capital appreciation, not rental income, current rents don't come close to justifying the growth in purchase price. Cities with a narrower gap, Duisburg at 20.8 points, Wiesbaden and Erfurt in the mid-30s, look more balanced from a rental yield standpoint.

For someone tracking city-level growth, Berlin's headline number deserves a second look before treating it as simple, sustained momentum. Berlin leads all 37 cities in cumulative real growth since 2012, but a year-over-year Z-score analysis shows its 2026 growth was actually negative, 3.57 percent below the prior year and well under the national average that year. A single strong multi-year total can still contain a recent slowdown, worth checking the recent trend specifically rather than relying on the full-period figure alone.

For anyone timing a purchase or a lending decision around interest rate movements, the data suggests the housing market doesn't respond to rate changes right away. A lag correlation test confirms this: time on market correlates most strongly with the interest rate from one year earlier (0.90), noticeably stronger than the same-year comparison (0.67) or a two year lag (0.65). Expecting an immediate shift in market speed the moment rates move isn't supported by this pattern, the effect shows up closer to a year later.

This project deliberately stops short of affordability claims. Without income or population data, there's no way to say whether housing has become harder to afford relative to what people earn, only that prices, rents, and sale activity have moved the way described above. Any recommendation implying affordability would go beyond what this data can support.

## SQL analysis

Nine cleaned tables are loaded into a PostgreSQL database (`shweta_housing`). Queries under `sql/` use CTEs, window functions (`RANK()`, `FIRST_VALUE`, `LAST_VALUE`, `LAG()`), and Z-score standardization to formalize the EDA findings directly in SQL, independent of the pandas analysis, and confirm they hold up.

- `01_city_price_growth.sql`: ranks all cities by average inflation-adjusted price
- `02_rent_price_divergence.sql`: calculates the rent-versus-sales growth gap per city
- `03_liquidity_vs_financing.sql`: joins yearly market liquidity against yearly interest rates
- `04_composite_pressure_score.sql`: combines year-over-year price growth with a Z-score against the national average to rank cities by relative housing market pressure, per year

## Project structure

```
data/raw/        original files, untouched
data/clean/       cleaned CSVs, output of the cleaning notebooks
notebooks/        cleaning, EDA, and PostgreSQL loading notebooks, numbered in run order
src/              shared code, including the city name mapping module
sql/              analytical SQL queries
powerbi/          Power BI dashboard file
```

## Limitations

The GREIX city sample (20 to 38 cities depending on the file) is a curated set of mostly larger and mid-size cities, not a complete national panel, so findings describe these tracked markets specifically, not all of Germany. The exact base period behind the price and rent indices isn't stated in the source files. National-level financing data can only be linked to city-level liquidity through the "Greix" national aggregate row, which is an approximation rather than a true weighted average of the specific tracked cities. No income or population data is included, so affordability as a trend over time isn't something this project can measure, only price, rent, and liquidity trends.

**Open question on units.** The `AVG_PRICE_SQM` values in `City_metrics_public.xlsx` range from about 4.6 to 27 across the dataset. Real German sale prices per square meter typically run into the thousands of euros, so this range doesn't look like a raw sale price. It sits much closer to GREIX's separately published rent-per-square-meter figures, for example München's published average rent is 23.35 EUR/sqm, close to this file's München maximum of 23.81. GREIX's own methodology documentation confirms their sales index is built from real transaction prices, not rent, but doesn't state the exact unit or scaling used in this specific public export column. This hasn't been resolved and is flagged here rather than assumed either way. Any claim in this README about absolute price levels (not growth rates, which are unaffected by a constant scaling factor) should be read with this caveat in mind until confirmed against GREIX directly.
