

SELECT * 
FROM PortfolioProject..CovidDeaths$ 
where continent is not null
order by 3,4

SELECT * FROM PortfolioProject..CovidVaccinations$ order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population_density
FROM PortfolioProject..CovidDeaths$ 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
where location like '%states%'
order by 1,2

-- looking at Total_Cases vs Population

SELECT location,date,total_cases,population_density, (total_cases/population_density)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths$ 
where location like '%a%'
order by 1,2

-- Countries with highest infection

SELECT location,MAX(total_cases) AS HighestInfection,population_density, MAX((total_cases/population_density))*100 
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$ 
GROUP BY location,population_density
order by PercentPopulationInfected

-- Showing Countries with highest death count population

SELECT location,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$ 
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

-- Let's break things down by continent

SELECT location,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$ 
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

-- Showing continents with highest death count per population


SELECT continent,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$ 
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)), 
((SUM(cast(new_deaths as int))) /(SUM(new_cases)+1)) * 100 
as DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
where continent is not null 

--GROUP BY date
order by 1,2


SELECT * FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date


-- total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population_density,vac.new_vaccinations,
      SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
	  as RollingPeopleVaccinated
	  --(RollingPeopleVaccinated/population)*1000
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3


-- USE CTE 

with PopVsVac(Continent, Location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population_density,vac.new_vaccinations,
      SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
	  as RollingPeopleVaccinated
	  --(RollingPeopleVaccinated/population)*1000
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population_density,vac.new_vaccinations,
      SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
	  as RollingPeopleVaccinated
	  --(RollingPeopleVaccinated/population)*1000
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to sroting data for later visualiztion

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population_density,vac.new_vaccinations,
      SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) 
	  as RollingPeopleVaccinated
	  --(RollingPeopleVaccinated/population)*1000
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3


SELECT * FROM PercentPopulationVaccinated











