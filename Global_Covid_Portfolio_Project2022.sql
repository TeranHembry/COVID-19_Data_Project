Select * 
FROM PortfolioProject..covid_deaths
WHERE continent is not null
ORDER BY location, date;

-- Select Data that we are going to work with
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
WHERE continent is not null AND location NOT LIKE '%income%'
ORDER BY location, date;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE location like '%states%' AND location NOT LIKE '%income%'
and continent is not null 
ORDER BY location, date;


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted Covid
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..covid_deaths
ORDER BY location, date;

-- Shows countries with the highest infection rate amongst its population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..covid_deaths
WHERE continent is not null AND location NOT LIKE '%income%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Shows countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is not null AND location NOT LIKE '%income%'
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- CONTINENT QUERIES 



--Shows continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE location NOT LIKE '%income%' AND continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- OR

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE location NOT LIKE '%income%' AND continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



--GLOBAL QUERIES


--Shows global cases and global deaths amongst cases
SELECT SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalDeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null 
ORDER by global_cases, global_deaths

--Shows highest death count per global income bracket
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is null AND location LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC;



--VACCINATION QUERIES



-- Join the data that we are going to work with
SELECT *
FROM PortfolioProject..covid_deaths AS cd
JOIN PortfolioProject..covid_vaccinations AS cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.location, cv.date;


-- Shows percentage of population that has recieved at least one covid vaccine using a CTE (common table expression)
WITH PopVac (continent, location, date, population, new_Vaccinations, accumlative_vaccinations)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS accumlative_vaccinations
FROM PortfolioProject..covid_deaths AS cd
JOIN PortfolioProject..covid_vaccinations AS cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
)

SELECT *, (accumlative_vaccinations/population) * 100 AS perc_vaccinated 
FROM PopVac

-- Creating a temp table for future visualizations

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
accumlative_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS int)) OVER (Partition by cd.Location Order by cd.location, cd.date) as accumlative_vaccinations
FROM PortfolioProject..covid_deaths AS cd
JOIN PortfolioProject..covid_Vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date


SELECT *, (accumlative_vaccinations/population)*100 as perc_vaccinated
FROM #PercentPopulationVaccinated
