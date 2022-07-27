--Covid 19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM PortfolioProject..Coviddeath
order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccination
order by 3,4
-- Selecting of data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Coviddeath
WHERE continent is not NULL
order by 1,2

--Looking at Total cases vs Total death
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 as DeathPercentage
FROM PortfolioProject..Coviddeath
where location like '%states%'
order by 1,2

-- Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..Coviddeath
--Where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as 
PercentPopulationInfected
FROM PortfolioProject..Coviddeath
WHERE continent is not NULL
Group by continent, location, population
order by PercentPopulationInfected desc

--Exploring by Continent
--Showing Continent with Higest Death Count per Population
SELECT continent , MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Coviddeath
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercent
FROM PortfolioProject..Coviddeath
WHERE continent is not NULL
--Group by date
order by 1,2


-- Looking at Total population vs  Total Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (continent, location, date, population, new_vaccinations,RoolingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RoolingPeopleVaccinated
FROM PortfolioProject..Coviddeath as dea
join PortfolioProject..CovidVaccination as vac
on dea.location = vac.location and 
dea.date = vac.date
WHERE dea.continent is not NULL)
SELECT *, (RoolingPeopleVaccinated/population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RoolingPeopleVaccinated numeric)

insert into  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RoolingPeopleVaccinated
FROM PortfolioProject..Coviddeath as dea
join PortfolioProject..CovidVaccination as vac
on dea.location = vac.location and 
dea.date = vac.date
WHERE dea.continent is not NULL
SELECT *, (RoolingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating views to store data for later visualization
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RoolingPeopleVaccinated
FROM PortfolioProject..Coviddeath as dea
join PortfolioProject..CovidVaccination as vac
on dea.location = vac.location and 
dea.date = vac.date
WHERE dea.continent is not NULL



SELECT *
FROM PercentPopulationVaccinated