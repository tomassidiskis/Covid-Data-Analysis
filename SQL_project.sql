-- Tableau visualization of this project:
-- https://public.tableau.com/app/profile/tomassidiskis/viz/CovidDashboardProject_16505651008590/Dashboard1

SELECT *
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PorfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%United kingdom%'
and continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population,(Total_cases/population)*100 AS CasesPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%United kingdom%'
and continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population

SELECT Location, max(total_cases) as HighesInfectionCount, population, max((Total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing continents with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated,
  (RollingPeopleVaccinated/population)*100
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

