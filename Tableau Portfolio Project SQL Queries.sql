/*
Queries used for Tableau Project
*/

--1
CREATE View PercentagePopulationVaccinated AS
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio.dbo.CovidDeaths dea
Join ProjectPortfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

--2 
CREATE View Overview AS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio.dbo.CovidDeaths
--Where location like '%France%'
where continent is not null 
--Group By date
--order by 1,2

--3 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

CREATE View DeathsPerContinents AS
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ProjectPortfolio.dbo.CovidDeaths
--Where location like '%France%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
--order by TotalDeathCount desc


--4.

CREATE View PercentPopulationInfected AS
Select continent, Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio.dbo.CovidDeaths
--Where location like '%France%'
where continent is not null 
Group by Continent, Location, Population, date
--order by PercentPopulationInfected desc


--5. 
CREATE View PercentDeathPopulationR AS
Select continent, Location, date, population, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--order by 1,2


