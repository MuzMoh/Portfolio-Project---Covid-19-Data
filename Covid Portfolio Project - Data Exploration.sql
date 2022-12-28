--select * from PortfolioProject..CovidDeaths
--order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Getting the data that I will be working with
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--Looking at total cases vs total deaths
--This shows the likelihood of dying if you contract Covid with respect to the country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--Looking at total cases vs population
--Shows percentage of population that got Covid
select location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
where location like 'Saudi Arabia'
and continent is not null 
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
where continent is not null 
group by population, location
order by Percent_Population_Infected desc


--Looking at countries with the highest deaths per population
select location, max(cast(total_deaths as int)) as Total_Deaths
from PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by Total_Deaths desc


--Looking at continents with the highest deaths per population
select continent, max(cast(total_deaths as int)) as Total_Deaths
from PortfolioProject..CovidDeaths
--where continent is not null 
group by continent
order by Total_Deaths desc


--Global cases, deaths and chance of death  everyday since first day of cases reported
select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2


--Global cases, deaths and chance of death
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



--Looking at total population vs new vaccinations per day
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated  --sum(convert(int,vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated	
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select *, (Rolling_People_Vaccinated/population)*100 as Percent_People_Vaccinated
from PopvsVac


--Temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar (255), 
Location nvarchar (255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated  --sum(convert(int,vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


select *, (Rolling_People_Vaccinated/population)*100 as Percent_People_Vaccinated
from PercentPopulationVaccinated


--Creating view to store data for later visualisation
create view PercentPopulationVaccinatedView as
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated  --sum(convert(int,vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.dateB
where dea.continent is not null 