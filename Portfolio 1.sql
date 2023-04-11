

SELECT date, CONVERT(date, Date)
FROM PortfolioProject..CovidDeaths

UPDATE PortfolioProject..CovidDeaths
SET date = CONVERT(date, Date)

--Temp Table of General Table (loc, pop, totcas, totdea)
DROP TABLE IF EXISTS #GeneralTable
CREATE TABLE #GeneralTable
(Location nvarchar (255),
Population numeric,
TotalCases numeric,
TotalDeaths numeric)

INSERT INTO #GeneralTable
SELECT Location, Population, MAX(total_cases), MAX(cast(total_deaths as int))
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY location

SELECT * 
FROM #GeneralTable

--Highest Cases

SELECT Location, Population, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY TotalCases DESC
--Or
SELECT * 
FROM #GeneralTable
ORDER BY TotalCases desc

--Highest Deaths

SELECT Location, Population, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC
--Or
SELECT * 
FROM #GeneralTable
ORDER BY TotalDeaths DESC

--Highest Precentage of Total Cases per Country's Population

SELECT *, (TotalCases/Population)*100 as TotalCasesPercentage
FROM #GeneralTable
ORDER BY TotalCasesPercentage desc

--Highest Precentage of Total Deaths per Country's Population

SELECT *, (TotalDeaths/Population)*100 as TotalDeathPercentage
FROM #GeneralTable
ORDER BY TotalDeathPercentage desc

--Highest Precentage of Total Deaths per Total Cases

SELECT *, (TotalDeaths/TotalCases)*100 as TotalDeathsPerCases
FROM #GeneralTable
ORDER BY TotalDeathsPerCases desc

--Percentage of Daily Death Rate per Cases

SELECT Location, date, new_cases, total_cases, new_deaths, total_deaths, (total_deaths/total_cases)*100	as DailyDeathPerCases
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY location, date

-- Temp Table of Daily Completed General Table

DROP TABLE IF EXISTS #DailyGeneralTable
CREATE TABLE #DailyGeneralTable
(Location nvarchar (255),
Population numeric,
Date date,
DailyCases numeric,
TotalDailyCases numeric,
DailyDeaths numeric,
TotalDailyDeaths numeric,
DailyVaccinations numeric,
TotalDailyVaccinations numeric)

INSERT INTO #DailyGeneralTable
SELECT dea.location, dea.population, CONVERT(date, dea.date) as date, new_cases, total_cases, new_deaths, total_deaths, vac.new_vaccinations, vac.total_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is not NULL

SELECT * 
FROM #DailyGeneralTable
ORDER BY 1,3

-- Daily Vaccinations Percentage
SELECT *, (TotalDailyVaccinations/Population)*100 as DailyVacPercentage
FROM #DailyGeneralTable
ORDER BY 1,3

-- Temp Table of Completed General Table (loc, pop, totcas, totdea, totvac)
DROP TABLE IF EXISTS #CompletedGeneralTable
CREATE TABLE #CompletedGeneralTable
(Location nvarchar (255),
Population numeric,
TotalCases numeric,
TotalDeaths numeric,
TotalVaccinations numeric)

INSERT INTO #CompletedGeneralTable
SELECT dea.location, dea.population, MAX(dea.total_cases), MAX(cast(dea.total_deaths as int)), MAX(vac.total_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location, dea.population
ORDER BY location

SELECT *
FROM #CompletedGeneralTable
ORDER BY Location

-- Highest Percentage of Vaccinations per Population

SELECT *, (TotalVaccinations/Population)*100 as TotVacPercentage
FROM #CompletedGeneralTable
ORDER BY TotVacPercentage desc

-- Data by Continents

SELECT Location, Population, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location, population

SELECT continent, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeaths desc

-- Global Numbers

SELECT dea.location, dea.population, MAX(dea.total_cases) as WorldCases, MAX(cast(dea.total_deaths as int)) as WorldDeaths, MAX(vac.total_vaccinations) as WorldVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.location = 'world'
GROUP BY dea.location, dea.population
ORDER BY location

-- CTE Global Data

WITH GlobalData (Location, Population, WorldCases, WorldDeaths, WorldVaccinations)
AS
(SELECT dea.location, dea.population, MAX(dea.total_cases), MAX(cast(dea.total_deaths as int)), MAX(vac.total_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.location = 'world'
GROUP BY dea.location, dea.population
)
-- Completed Global Data

SELECT *, (WorldCases/Population)*100 as CaseRate, (WorldDeaths/Population)*100 as DeathRate, (WorldDeaths/WorldCases)*100 as DeathPerCasesRate, (WorldVaccinations/Population)*100 as VaccinationRate
FROM GlobalData

-- Creating View for Visualization

CREATE VIEW CompletedTotalTable as
SELECT dea.location, dea.population, MAX(dea.total_cases) as TotalCases, MAX(cast(dea.total_deaths as int)) as TotalDeaths, MAX(vac.total_vaccinations) as TotalVacs
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location, dea.population

SELECT *
FROM CompletedTotalTable
