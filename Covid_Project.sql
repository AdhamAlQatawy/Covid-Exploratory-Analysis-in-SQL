/*Exploring the data*/

SELECT location, date, total_cases, new_cases, total_deaths,  population
FROM SQLProjects..CovidDeaths
order by location, date


-- exploring Cases and deaths 
SELECT continent, location, date, population , new_cases, new_deaths, total_cases,  total_deaths
FROM SQLProjects..CovidDeaths
where continent is not null and total_cases <> 0 
order by location, date


-- Investigatin the countries percentage of infection and deaths
SELECT continent, location, population, max(total_cases) as Total_Infection, (max(total_cases)/population)*100 as Infection_Percentages, 
max(cast(total_deaths as int)) as Total_Deaths, (max(cast(total_deaths as int))/max(total_cases))*100 as Death_Percentages
FROM SQLProjects..CovidDeaths
where continent is not null and total_cases <> 0 
group by continent, location, population
order by Location 


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
Creating a CTE to get the right numbers for total cases per continen
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


-- The total statistics around the world
SELECT max(total_cases) as total_cases, max(cast(total_deaths as int)) as total_deaths, 
 max(cast(total_deaths as int))/ max(total_cases)*100 as DeathPercentage
FROM SQLProjects..CovidDeaths
where continent is not null 

 --Vaccination Statistics
with VacPercentage (continent, location, population, People_Vaccinated) 
as(
select cd.continent, cd.location, cd.population
, max(cast(cv.people_fully_vaccinated as int)) as People_Vaccinated
from SQLProjects..CovidDeaths as cd
inner join SQLProjects..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
group by cd.continent, cd.location, cd.population
) 
select continent, location, population, sum(people_Vaccinated) as PeopleVaccinated, (sum(People_Vaccinated)/sum(population))*100 as PeopleFullyVaccinatedPercentage
from VacPercentage
where population is not null
group by continent, location, population

------------------------------------------------------------------------------------------------------------------------------------

/*Cleaning the Data*/

--Replacing all NULL values with 0 to use it in Visualization
UPDATE SQLProjects..CovidVaccinations
SET new_vaccinations=0
WHERE new_vaccinations IS NULL;

UPDATE SQLProjects..CovidDeaths
SET total_cases=0
WHERE total_cases IS NULL; 


UPDATE SQLProjects..CovidDeaths
SET new_cases=0
WHERE new_cases IS NULL; 


UPDATE SQLProjects..CovidDeaths
SET new_deaths=0
WHERE new_deaths IS NULL; 


UPDATE SQLProjects..CovidVaccinations
SET people_fully_vaccinated=0
WHERE people_fully_vaccinated IS NULL; 


--Replacing continent NULL values for the world to WorldWide
UPDATE SQLProjects..CovidDeaths
SET continent= 'World'
WHERE location = 'World';


--Replacing continent NULL values for the world to WorldWide
UPDATE SQLProjects..CovidVaccinations
SET continent= 'World'
WHERE location = 'World';

 ------------------------------------------------------------------------------------------------------------------------------------

/*Creating Views for Visualizations*/

--Cases and deaths 
CREATE OR ALTER VIEW CasesAndDeaths as 
SELECT continent, location as country, date, population , new_cases, new_deaths, total_cases, total_deaths
FROM SQLProjects..CovidDeaths
where continent is not null and total_cases <> 0 


--countries percentage of infection and deaths
CREATE or alter VIEW InfectionsAndDeathsPercentages as 
SELECT continent, location, population, max(total_cases) as Total_Infection, (max(total_cases)/population)*100 as Infection_Percentage, 
max(cast(total_deaths as int)) as Total_Deaths, (max(cast(total_deaths as int))/max(total_cases))*100 as Death_Percentages
FROM SQLProjects..CovidDeaths
where continent is not null and total_cases <> 0 
group by continent, location, population


--number of infections at each continent 
CREATE or alter VIEW CasesNumbersPerContinent as
with new_CovidCases (continent, total_cases) as 
(
SELECT continent, sum(total_cases) as total_cases
FROM SQLProjects..CovidDeaths
where continent is not null and continent <> 'World'
group by continent, date
)
select continent, max(total_cases) as total_cases
from new_CovidCases
group by continent


--number of deaths at each continent 
CREATE or alter VIEW DeathsNumbersPerContinent as
with new_CovidDeaths (continent, total_deaths) as 
(
SELECT continent, sum(cast(new_deaths as int)) as total_deaths
FROM SQLProjects..CovidDeaths
where continent is not null and continent <> 'World'
group by continent
)
select continent, max(total_deaths) as total_deaths
from new_CovidDeaths
group by continent


-- The total statistics around the world
CREATE or alter VIEW TotalStatistics as
SELECT max(total_cases) as total_cases, max(cast(total_deaths as int)) as total_deaths, 
 max(cast(total_deaths as int))/ max(total_cases)*100 as DeathPercentage
FROM SQLProjects..CovidDeaths
where continent is not null and continent = 'WorldWide'


--Vaccination Statistics 
CREATE OR ALTER VIEW TotalVaccinated as
with VacPercentage (continent, location, population, People_Vaccinated) 
as(
select cd.continent, cd.location, cd.population
, max(cast(cv.people_fully_vaccinated as int)) as People_Vaccinated
from SQLProjects..CovidDeaths as cd
inner join SQLProjects..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
group by cd.continent, cd.location, cd.population
) 
select location, sum(population) as population, sum(people_Vaccinated) as PeopleVaccinated, (sum(People_Vaccinated)/sum(population))*100 as PeopleVaccinatedPercentages
from VacPercentage
where population is not null 
group by location
having (sum(People_Vaccinated)/sum(population))*100 < 100
 