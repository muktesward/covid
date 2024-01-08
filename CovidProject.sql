select * from Covid_Vaccination

SELECT count (column_name) as Number FROM information_schema.columns WHERE table_name='Covid_Vaccination'

--SELECT the data that we are going to use 
select location,continent,
date, total_cases, new_cases, total_deaths, population
from Covid_Deaths
where continent is not null
order by 1,2

--Looking at total cases and total deaths
--shows the liklihood of dying if u contract covid in your country
select location, date, total_cases, total_deaths
,cast(total_deaths as float)/ cast(total_cases as float) * 100 as DeathPercentage
from Covid_Deaths where location like '%India%' and 
 continent is not null
order by 1,2

--Looking at total cases vs Populaiton 
--shows what percentage got covid

select location, date, total_cases, population
,cast(total_cases as float)/ cast(population as float) * 100 as PercentPopulationInfected
from Covid_Deaths --where location like '%India%'
where continent is not null
order by 1,2

-- Looking at coutries that has highest infection rate compared to population
select location,max(total_cases) as HighestInfectionCount, population
,max(cast(total_cases as float)/ cast(population as float)) * 100 as PercentPopulationInfected
from Covid_Deaths -- where location like '%India%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as HighestDeathCount, population
,max(cast(total_deaths as float)/ cast(population as float)) * 100 as PercentPopulationDeath
from Covid_Deaths -- where location like '%India%'
where continent is not null
group by location, population
order by location,PercentPopulationDeath desc
--
select location,max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Deaths -- where location like '%India%'
where continent is not null
group by location, population
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Deaths -- where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

--
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Deaths -- where location like '%India%'
where continent is not null -- and location  not like '%Income%'
group by continent
order by TotalDeathCount desc

--Showing continents with highest death count
--select continent, max
--from Covid_Deaths

--GLOBAL NUMBERS

select  sum(cast(total_cases as float)) as Total_Cases, sum(cast(new_deaths as float)) as Total_Deaths
,sum(cast(new_deaths as float))/sum(cast(total_cases as float)) * 100 as DeathPercentage 
from Covid_Deaths
where continent is not null
--group by date
--order by  date

--LOOKNG AT total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid_Deaths dea
join Covid_Vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3

--The dates when the country started vaccinations
select dea.continent, dea.location, min(dea.date) as [Vaccination Start Date]--, dea.population --, vac.new_vaccinations
from Covid_Deaths dea
join Covid_Vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
group by dea.continent, dea.location
order by 2,3

-- WITH CTE

with PopvsVac ( continent , locatioin, date, population, new_vaccinations, RolliingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid_Deaths dea
join Covid_Vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RolliingPeopleVaccinated/population)*100  as [Rolling % People Vaccinated] 
from PopvsVac

-- WITH TEMP TABLE
drop table if exists #PercentagePeopleVaccinated
create table #PercentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentagePeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid_Deaths dea
join Covid_Vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100  as [Rolling % People Vaccinated] 
from #PercentagePeopleVaccinated

-- Create view 
create view PercentPopolationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid_Deaths dea
join Covid_Vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopolationVaccinated