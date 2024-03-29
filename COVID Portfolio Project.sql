/*
Portfolio Project_1: Covid Cases Data
*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2  -- Organized data

-- Looking at Total cases VS Total deaths in percentage
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%India%'
--ORDER BY 1,2


-- Looking at Total cases VS Population
-- shows what percentage of population get covid
SELECT location, date,population, total_cases, (total_cases/population)*100 AS PopulationGotCovid_Percentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%India%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with higher Infection Rate compared to Population

SELECT location, population, MAX(total_cases)AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%India%' AND continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

-- Showing the Countries with highest Death Count per Population 

SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount desc, 1,2

-- Showing Continents with the highest death count per population
-- Lets Break things down by Continent 
-- based on location and  null value

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%India%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global numbers 

SELECT SUM(new_cases) TOTAL_NEWCASES, SUM(CAST (new_deaths AS INT)) TOTAL_NEWDEATHS, SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100  AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- JOIN TWO TABLES 
-- Looking at Total Population vs Vaccinations


-- Use CTE 
WITH PopVSVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CONVERT(INT ,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac








-- TEMP TABLE 


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CONVERT(INT ,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated







-- Creating view to store data for later visualization


DROP VIEW IF EXISTS PercentPopulationVaccinated
--

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT *
FROM PercentPopulationVaccinated




