/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM ProjectPortfolio.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM ProjectPortfolio.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be starting with 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at the Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in France 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio.dbo.CovidDeaths
WHERE location Like '%France%'
AND continent is not null
ORDER BY 1,2


-- Looking at Total Cases VS Population
-- Shows What percentage of population infected with covid

SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectPortfolio.dbo.CovidDeaths
--WHERE location Like '%France%'
ORDER BY 1,2


--Looking at countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM ProjectPortfolio.dbo.CovidDeaths
--WHERE location Like '%France%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing the countries with the Highest Death Count per Population

SELECT location, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM ProjectPortfolio.dbo.CovidDeaths
--WHERE location Like '%France%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the continent with the highest death count per population

SELECT continent, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM ProjectPortfolio.dbo.CovidDeaths
--WHERE location Like '%France%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectPortfolio.dbo.CovidDeaths
--WHERE location Like '%France%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total population VS Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio.dbo.CovidDeaths AS dea
JOIN ProjectPortfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE to perform Calculation on Partition By in previous query

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio.dbo.CovidDeaths AS dea
JOIN ProjectPortfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



--USE TEMP TABLE to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio.dbo.CovidDeaths AS dea
JOIN ProjectPortfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data from later Visualizations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio.dbo.CovidDeaths AS dea
JOIN ProjectPortfolio.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated 
