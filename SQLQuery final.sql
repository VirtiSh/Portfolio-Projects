--1.

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, 
(SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- we exclude locations world, International, European Union
--European Union is part of Europe

--2.
SELECT location, SUM(cast(new_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'International', 'European Union', 'Upper middle income', 
'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count desc

--3.
SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/ population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected Desc


--4.
SELECT location, population, date, max(total_cases) as HighestInfectionCount, 
max(total_cases / population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc