# COVID-19 Data Exploration (SQL)

Exploratory analysis of global COVID-19 data using SQL Server, 
with a focus on Australia and the relationship between government 
lockdown measures and transmission rates.

Data source: [Alex Freberg's COVID-19 Portfolio Project](https://github.com/AlexTheAnalyst/PortfolioProjects)

---

## Analysis Overview

### Global Overview
- Death percentage by country (total deaths vs total cases)
- Population infection rate by country
- Countries ranked by highest infection rate
- Countries ranked by highest death count and death rate
- Continental death count breakdown
- Global totals — cases, deaths, overall death percentage

### Australia Deep Dive
Day-by-day breakdown of Australia's COVID journey including new cases, 
deaths, ICU pressure, government stringency, and vaccination progress 
— all joined from two data sources.

### Reproduction Rate vs Stringency Index
Analyses whether government lockdown measures actually affected 
COVID transmission rates globally. Uses a 7-day LAG window function 
to account for the delay between policy changes and their effect 
on the reproduction rate (R value). Each country-date is labelled 
as Spreading (R > 1), Stable (R = 1), or Shrinking (R < 1).

---

## SQL Skills Demonstrated

| Skill | Where used |
|---|---|
| JOIN (multi-condition) | Australia deep dive |
| Window Functions | Rolling vaccination total, 7-day LAG |
| CTE | Reproduction rate analysis |
| Temp Table | Reproduction rate analysis |
| View | ReproductionVsStringency (for Power BI) |
| Aggregate Functions | Death counts, infection rates |
| CAST / Type Conversion | nvarchar to float throughout |
| NULLIF | Prevent divide by zero errors |
| CASE WHEN | Outbreak status labelling |
| FORMAT | Percentage display formatting |

---

## Tools
- SQL Server Management Studio
- Power BI (coming soon)

---

## Key Findings
- Highest death rates are not always in the highest case count countries
- Australia maintained relatively low ICU pressure compared to case counts
- Reproduction rate (R value) shows clear correlation with stringency 
  index changes when accounting for a 7-day policy delay
