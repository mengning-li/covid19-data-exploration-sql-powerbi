/*
================================================
Covid 19 Data Exploration
Author: Melanie Li
Date: April 2026
Tools: SQL Server Management Studio

Description: 
Exploratory analysis of global COVID-19 data
covering cases, deaths, vaccinations, and 
government response measures.
Includes Australia-specific deep dive and
reproduction rate vs stringency analysis.

Skills demonstrated: 
Joins, CTEs, Temp Tables, Window Functions,
Aggregate Functions, Views, Type Conversion,
LAG, CASE WHEN, NULLIF
================================================
*/



-- =============================================
-- GLOBAL OVERVIEW
-- =============================================

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Australia

Select Location, date, total_cases, total_deaths, 
    CAST(total_deaths AS float)/NULLIF(total_cases, 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%australia%'
and continent is not null 
order by 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, 
    FORMAT((CAST(total_cases AS float) / NULLIF(population, 0)) * 100, '0.00000') as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%australia%'
order by 1,2



-- Countries with Highest Infection Rate compared to Population

Select Location, Population, 
    MAX(total_cases) as HighestInfectionCount,  
    MAX(CAST(total_cases AS float)/NULLIF(population, 0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Countries with Highest Death Rate

Select Location, 
    MAX(cast(Total_deaths as int)) as TotalDeathCount, 
    MAX(cast(total_deaths as float)) / NULLIF(MAX(population), 0) * 100 as Death_rate
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by Death_rate desc



-- =============================================
-- CONTINENTAL BREAKDOWN
-- =============================================

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



 --=============================================
 --GLOBAL NUMBERS
 --=============================================

Select 
    'Global' as Location, 
    SUM(new_cases) as total_cases, 
    SUM(cast(new_deaths as int)) as total_deaths, 
    CAST(SUM(cast(new_deaths as int)) AS float)/NULLIF(SUM(New_Cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 




-- Australia Deep Dive
-- Shows cases, deaths, ICU pressure and vaccination
-- progress over time for Australia specifically

SELECT 
    dea.location,
    dea.date,
    dea.new_cases,
    dea.new_deaths,
    dea.icu_patients,
    CAST(dea.stringency_index AS float) as stringency_index,
    vac.new_vaccinations,
    vac.people_fully_vaccinated_per_hundred
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.location = 'Australia'
ORDER BY dea.date



-- Reproduction Rate vs Stringency Index
-- Analyses whether government lockdown measures
-- affected COVID transmission rates globally

SELECT location, date,
    CAST(reproduction_rate AS float) as reproduction_rate,
    CAST(new_cases AS float) as new_cases,
    CAST(stringency_index AS float) as stringency_index
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
AND reproduction_rate is not null
ORDER BY location, date



-- Reproduction Rate vs Stringency — CTE Method
-- Uses 7 day LAG to account for delay between
-- policy change and effect on transmission rate

WITH ReproductionAnalysis AS (
    SELECT 
        location,
        date,
        CAST(reproduction_rate AS float) as reproduction_rate,
        CAST(stringency_index AS float) as stringency_index,
        CAST(new_cases AS float) as new_cases,
        CAST(LAG(stringency_index, 7) OVER (
            PARTITION BY location 
            ORDER BY date
        ) AS float) as stringency_7days_ago
    FROM PortfolioProject..CovidDeaths
    WHERE continent is not null
    AND reproduction_rate is not null
)
SELECT *,
    CASE 
        WHEN reproduction_rate > 1 THEN 'Spreading'
        WHEN reproduction_rate = 1 THEN 'Stable'
        ELSE 'Shrinking'
    END as OutbreakStatus
FROM ReproductionAnalysis
ORDER BY location, date



-- Reproduction Rate vs Stringency — Temp Table Method

DROP TABLE IF EXISTS #ReproductionAnalysis

CREATE TABLE #ReproductionAnalysis (
    location nvarchar(255),
    date datetime,
    reproduction_rate float,
    stringency_index float,
    new_cases float,
    stringency_7days_ago float,
    OutbreakStatus nvarchar(50)
)

INSERT INTO #ReproductionAnalysis
SELECT 
    location,
    date,
    CAST(reproduction_rate AS float),
    CAST(stringency_index AS float),
    CAST(new_cases AS float),
    CAST(LAG(stringency_index, 7) OVER (
        PARTITION BY location 
        ORDER BY date
    ) AS float),
    CASE 
        WHEN CAST(reproduction_rate AS float) > 1 THEN 'Spreading'
        WHEN CAST(reproduction_rate AS float) = 1 THEN 'Stable'
        ELSE 'Shrinking'
    END
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
AND reproduction_rate is not null

SELECT * FROM #ReproductionAnalysis
ORDER BY location, date



-- Reproduction Rate vs Stringency — View Method
-- Connect Power BI directly to this view

DROP VIEW IF EXISTS ReproductionVsStringency

CREATE VIEW ReproductionVsStringency AS
SELECT 
    location,
    date,
    CAST(reproduction_rate AS float) as reproduction_rate,
    CAST(stringency_index AS float) as stringency_index,
    CAST(new_cases AS float) as new_cases,
    CAST(LAG(stringency_index, 7) OVER (
        PARTITION BY location 
        ORDER BY date
    ) AS float) as stringency_7days_ago,
    CASE 
        WHEN CAST(reproduction_rate AS float) > 1 THEN 'Spreading'
        WHEN CAST(reproduction_rate AS float) = 1 THEN 'Stable'
        ELSE 'Shrinking'
    END as OutbreakStatus
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
AND reproduction_rate is not null

-- Query the view — filter to Australia for focused analysis
SELECT * FROM ReproductionVsStringency
WHERE location = 'Australia'
ORDER BY date

