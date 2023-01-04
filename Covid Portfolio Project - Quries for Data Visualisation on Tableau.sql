/*
Queries used for Tableau Project
*/

-- 1. Death Percentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_Cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- 2. Total Death Count in each continent

-- We take these out as they are not included in the above query and want to stay consistent
-- European Union is part of Europe

select location, sum(cast(new_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location
order by Total_Death_Count desc


-- 3.Percentage of population infected by location

select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
where location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by Location, Population
order by Percent_Population_Infected desc


-- 4. Countries with highest infection rate compared to population

select Location, Population,date, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
where location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by Location, Population, date
order by Percent_Population_Infected desc

