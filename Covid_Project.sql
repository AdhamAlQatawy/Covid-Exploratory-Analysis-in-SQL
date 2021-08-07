
SELECT location, date, total_cases, new_cases, total_deaths,  population
FROM SQLProjects..CovidDeaths
order by location, date


-- exploring the Death Percentage 
SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQLProjects..CovidDeaths
where continent is not null 
order by location, date


-- exploring the Cases Percentage
SELECT continent, location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM SQLProjects..CovidDeaths
where continent is not null 
order by location, date


--explroing the countries with the highest infections 
SELECT continent, location, population, max(total_cases) as Total_Infection
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent, location, population
order by Total_Infection desc


-- Investigatin the countries with the highest percentage of infection
SELECT continent, location, population, max(total_cases) as Total_Infection, max((total_cases/population))*100 as Infection_Percentage
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent, location, population
order by Infection_Percentage desc


-- Invistigating the countries with the highest number of deaths
SELECT continent,location, population, max(cast(total_deaths as int)) as Total_Deaths
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent,location, population 
order by Total_Deaths desc


-- Invistigating the countries with the highest percentage of deaths
SELECT continent, location, population, max(cast(total_deaths as int)) as Total_Deaths, max((cast(total_deaths as int))/population)*100 as Death_Percentage
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent, location, population 
order by Death_Percentage desc


-- investigatin the continent with the highest number of deaths
SELECT continent, max(cast(total_deaths as int)) as Total_Deaths
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent
order by Total_Deaths desc


-- after figuring that there is something wrong with the data
-- I'm exploring the continent column
SELECT continent,location, date, new_cases,  total_cases,total_deaths
FROM SQLProjects..CovidDeaths
where continent is null 
order by location asc
-- found that there is NULL values in continent column 
-- and the rows that have NULL values in continent has the continent name in location column 


-- Getting the number of infections at each continent 
-- we can get it with two ways, the first is:
/* 
Creating a CTO to get the right numbers for total cases per continen
by getting the sum of the infections number for all the locations per continent and date
then retrieving the max number for each continent 
*/
with new_CovidCases (continent, total_cases) as 
(
SELECT continent, sum(total_cases) as total_cases
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent, date
)
select continent, max(total_cases) as total_cases
from new_CovidCases
group by continent
order by total_cases desc


-- the second one is:
/* 
as before we get the sum of the infections number for all the locations per continent only
then then retrieving the max number for each continent 
*/
with new_CovidCases (continent, total_cases) as 
(
SELECT continent, sum(new_cases) as total_cases
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent
)
select continent, max(total_cases) as total_cases
from new_CovidCases
group by continent
order by total_cases desc


-- Getting the number of deaths at each continent 
with new_CovidDeaths (continent, total_deaths) as 
(
SELECT continent, sum(cast(new_deaths as int)) as total_deaths
FROM SQLProjects..CovidDeaths
where continent is not null 
group by continent
)
select continent, max(total_deaths) as total_deaths
from new_CovidDeaths
group by continent
order by total_deaths desc


-- The total death percentage around the world
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM SQLProjects..CovidDeaths
where continent is not null


-- Getting the vaccinated people's percentage
with VacPercentage (continent, location, date, population, new_vaccinations, People_Vaccinated_Percentage) 
as(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as People_Vaccinated_Percentage
from SQLProjects..CovidDeaths as cd
inner join SQLProjects..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
) 
select *, (People_Vaccinated_Percentage/population)*100 as People_Vaccinated_Percentage
from VacPercentage


