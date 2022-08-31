Select *
FRom PortfolioProject..CovidDeaths
order by 3,4

---Select Data thaqt we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- looking at the total cases vs the total deaths
-- shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases,  total_deaths
		,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
and location like '%states%'
order by 1,2


--Looking at Total Cases vs the population
--Shows what percentage of population got covid
Select Location, date, population, total_cases 
		,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
and location like '%states%'
order by 1,2


-- Looking at Countries with the Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
GROUP BY Location, population
order by 4 desc


-- SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT 
Select Location
, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
GROUP BY Location
order by 2 desc


-- SHOWING THE Continents WITH THE HIGHEST DEATH COUNT 
Select continent
, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
GROUP BY continent
order by 2 desc



-- SHOWING THE Continents WITH THE HIGHEST DEATH COUNT ----Correct
Select Location
, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null
and location not like '%income%'
GROUP BY Location
order by 2 desc


--Global Numbers
Select date
, sum(new_cases) as total_cases
,sum(cast(new_deaths as int)) as total_deaths
,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY date
order by 1,2



---looking at Total Population vs Vaccination
select dea.continent
, dea.location
, dea.date
, dea.population
, vax.new_vaccinations
, sum(CONVERT(int,vax.new_vaccinations)) OVER (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
ON dea.location =vax.location
and dea.date =vax.date
where dea.continent is not null
order by 1,2,3


---make note of big int ~57 mins
select dea.continent
, dea.location
, dea.date
, dea.population
, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVax

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
ON dea.location =vax.location
and dea.date =vax.date
where dea.continent is not null
order by 2,3


---USE CTE

With PopVsVax (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVax)
as
(
select dea.continent
, dea.location
, dea.date
, dea.population
, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVax

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
ON dea.location =vax.location
and dea.date =vax.date
where dea.continent is not null
--order by 2,3
)


Select * 
		,(RollingPeopleVax/Population) *100 

From PopVsVax


---creating view
create view vs_PercentPopulationVax as 
select dea.continent
, dea.location
, dea.date
, dea.population
, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVax
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
ON dea.location =vax.location
and dea.date =vax.date
where dea.continent is not null
--order by 2,3

select * from vs_PercentPopulationVax





