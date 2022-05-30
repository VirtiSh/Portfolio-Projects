SELECT *
--FROM PortfolioProject..CovidDeaths
FROM Portfolioproject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
----FROM PortfolioProject..CovidDeaths
--FROM Portfolioproject.dbo.CovidVaccination
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject..CovidDeaths
ORDER BY 1,2

--how many cases are there in country and
--how many deaths do they have from entire cases
--e.g 1000 peaople that have been diagnosed, they had 10 people who died,
--whats the percentage of people who died

-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, CONCAT(((total_deaths/total_cases)*100), '%') as DeathPercent
FROM PortfolioProject..CovidDeaths

--Looking at total cases vs population
--shows what percentage of population got infected

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- looking at countries with highest infection rate compared to the population

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

-- showing the countries with the highest death count per population.

SELECT location, max(convert(int, total_deaths)) as TotalDeathCount
-- converted the total_death from nvarchar(255) data type to int 
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Afghanistan'
GROUP BY location
ORDER BY TotalDeathCount desc

--OR

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
-- converted the total_death from nvarchar(255) data type to int 
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Afghanistan'
GROUP BY location
ORDER BY TotalDeathCount desc

-- in above generated data in location section we have few locations that shouldn't be there e.g.: world, south america, africa these are grouping entire continents

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
-- converted the total_death from nvarchar(255) data type to int 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Afghanistan'
GROUP BY location
ORDER BY TotalDeathCount desc

-- breaking things by continent

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
-- converted the total_death from nvarchar(255) data type to int 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--showing the continents with the highest death count

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
-- converted the total_death from nvarchar(255) data type to int 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--(calculate everything across the entire world i.e. not filtering by location or continent, 
--(it will give total accross the world)

--GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 desc

--Overall across the world
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 desc

--(Joining 2 tables coviddeaths and covidvaccination)
-- Looking at total population vs Vaccination (i.e. total amount of people in the world that have been vaccinated)

--USING EITHER WITH CLAUSE

WITH CTE as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND dea.location = 'Afghanistan'
--AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated / population) * 100
FROM CTE 	

--OR USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(bigint, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location 
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated / population) * 100
FROM #PercentPopulationVaccinated


 --CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(bigint, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

DROP VIEW PercentPopulationVaccinated
