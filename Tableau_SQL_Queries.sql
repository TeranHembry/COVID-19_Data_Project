-- Queries used for data visualizations in Tableau

-- Total cases, total deaths, death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
where continent is not null 
order by 1,2

-- Death count by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE location NOT LIKE '%income%' AND continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Case count by country
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Case count by country over time
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc
