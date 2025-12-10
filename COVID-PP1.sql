SELECT *
FROM PortfolioProject..CovidDeaths$
order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
Order by 1,2

--total cases vs Total Deaths
--Shows the likelihood of dying if a person gets covid in a nation
select Location, date, total_cases ,total_deaths,(total_cases/Population)*100 as Death_percentage
FROM PortfolioProject..CovidDeaths$
where location like '%Afghanistan%'
Order by 1,2

--total_cases vs population
Select Location, date, Population,total_cases,(total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Order by 1,2

--Countries with Highest Infection Rate compared to Population

select Location, population,MAX(total_cases) as Highest_Infection_Count ,MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Group By location,population
Order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
select Location,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group By location
Order by Total_Death_Count desc

--Continent
select continent,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group By continent
Order by Total_Death_Count desc

--Showing the continent with highest deaths rate 
select continent,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group By continent
Order by Total_Death_Count desc

--Global Numbers
select SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_Death,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
--Group By date
Order by 1,2

--Looking at Total Population vs Vaccinations
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.location Order By de.Location,de.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ de
Join PortfolioProject..CovidVaccinations$ va
	On de.location = va.location
	and de.date=va.date
where de.continent is  not null
order by 2,3

--CTE
with PopvsVac( continent,location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.location Order By de.Location,de.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ de
Join PortfolioProject..CovidVaccinations$ va
	On de.location = va.location
	and de.date=va.date
where de.continent is  not null
)
SELECT *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TTABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.location Order By de.Location,de.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ de
Join PortfolioProject..CovidVaccinations$ va
	On de.location = va.location
	and de.date=va.date
SELECT *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View 

IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;
GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
       SUM(CONVERT(int, va.new_vaccinations)) OVER 
           (PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ de
JOIN PortfolioProject..CovidVaccinations$ va
    ON de.location = va.location
   AND de.date = va.date
WHERE de.continent IS NOT NULL;
GO

SELECT *
FROM PercentPopulationVaccinated;

