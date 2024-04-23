--Examining the data

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..Vaccinations


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Now I will look at Total Cases vs Total Deaths 
--Also shows the likelihood of dying in the US

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--This is Total Cases vs Population

SELECT location, date, total_cases, population, CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100 AS infected_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, CAST(MAX(total_cases) AS FLOAT)/CAST(population AS FLOAT)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Death Count in each Continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, CAST(SUM(new_deaths) AS decimal)/CAST(SUM(new_cases) AS decimal)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, CAST(SUM(new_deaths) AS decimal)/CAST(SUM(new_cases) AS decimal)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Now let's join our two tables
--I will be looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac. location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Making a Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cumulative_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac. location
	AND dea.date = vac.date

SELECT *, (cumulative_vaccinations/Population)*100
FROM #PercentPopulationVaccinated



--Now I am creating views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac. location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

CREATE VIEW view2 AS
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, CAST(MAX(total_cases) AS FLOAT)/CAST(population AS FLOAT)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population

--These are the queries I will use for Tableau

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  CAST(MAX(total_cases) AS FLOAT)/CAST(population AS FLOAT)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  CAST(MAX(total_cases) AS FLOAT)/CAST(population AS FLOAT)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc