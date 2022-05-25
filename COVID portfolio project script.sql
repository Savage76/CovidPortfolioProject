select *from PortfolioProject..covidDeaths
where continent is not null
order by 3,4


select *from PortfolioProject..covidVaccinations
order by 3,4

-- select data that we are going to be using

select Location , date , total_cases , new_cases , total_deaths , population
from PortfolioProject..covidDeaths 
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- shows likelihood of dying if you contract Covid in your country

select Location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..covidDeaths 
where location ='Nigeria'
order by 1,2

-- Looking at Total cases vs Population
-- shows what percentage of population got Covid

select Location , date ,population, total_cases , (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..covidDeaths 
--where location ='Nigeria'
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate
select Location,population, max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..covidDeaths 
--where location ='Nigeria'
where continent is not null
group by location,population
order by PercentagePopulationInfected desc

-- Showing Countries with highest Death count per population 
select location, max( cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..covidDeaths 
--where location ='Nigeria'
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest Death count per population
select continent, max( cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..covidDeaths 
--where location ='Nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

select sum(new_cases)as total_cases ,sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..covidDeaths 
--where location ='Nigeria'
where continent is not null
--group by date
order by 1,2



-- Looking at Total Population vs Vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,sum(cast( vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths as Dea
join PortfolioProject..covidVaccinations as Vac
on Dea.Location=Vac.location
and Dea.Date=Vac.Date
where dea.continent is not null
order by 2,3



--USE CTU

With PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths Dea
join PortfolioProject..covidVaccinations Vac
    on Dea.Location=Vac.location
    and Dea.Date=Vac.Date
where dea.continent is not null
--order by 2,3
) 
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths Dea
join PortfolioProject..covidVaccinations Vac
    on Dea.Location=Vac.location
    and Dea.Date=Vac.Date
--where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths Dea
join PortfolioProject..covidVaccinations Vac
    on Dea.Location=Vac.location
    and Dea.Date=Vac.Date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated

