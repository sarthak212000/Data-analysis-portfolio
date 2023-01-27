--Covid-19 Data exploration
--Skills implemented: CTE'S, Windows Function, Joins, Converting Data Types, Aggreagate functions, Temp Tables



-- selected all the data from  coviddeath
SELECT * 
FROM coviddeath
ORDER BY 3,4;


SELECT * 
FROM covidvaccination
ORDER BY 3,4;

--now selecting those data which we are going to work with

SELECT 
location, 
population, 
date_d, 
total_cases, 
new_cases, 
total_death
FROM coviddeath
ORDER BY 1,2;

--looking at total deaths vs total cases
-- It is showing the likelihood of dying if you contract in India

SELECT 
location,  
date_d, 
total_cases,  
total_death,
(total_death/total_cases)*100 as Deathpercentage
FROM coviddeath
WHERE location LIKE '%afghanistan%'
ORDER BY 1,2;

--looking at total cases vs population

SELECT 
location,  
date_d, 
population,  
total_cases,
(population/total_cases)*100 as Deathpercentage
FROM coviddeath
--WHERE location LIKE '%afghanistan%'
ORDER BY 1,2;


--looking at countries with highest infection rate compared to population

SELECT 
location,
population,  
MAX(total_cases) AS highestInfestioncount,
MAX((total_cases/population))*100 as percentagePopulationInfected
FROM coviddeath
--WHERE location LIKE '%India%'
GROUP BY location,population
ORDER BY percentagePopulationInfected desc;

--demonstrating countries with highest death count per population

SELECT 
location,  
MAX(CAST(total_cases AS INT)) AS totaldeathcount
FROM coviddeath
--WHERE location LIKE '%afghanistan%'
GROUP BY location,population
ORDER BY totaldeathcount desc;

--Breaking things down by continent
--demonstrating continents with the highest death count per population


SELECT 
continent,  
MAX(CAST(total_cases AS INT)) AS totaldeathcount
FROM coviddeath
--WHERE location LIKE '%afghanistan%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount desc;

--Global numbers

SELECT
SUM (new_Cases) AS total_Cases,
SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as Deathpercentage
FROM coviddeath
--WHERE location LIKE '%afghanistan%'
WHERE continent IS NOT NULL
--GROUP BY date_d 
ORDER BY 1,2;

--looking at vaccinations vs population

SELECT
dea.continent,
dea.date_d,
dea.location,
dea.population,
vac.new_vaccination,
SUM(CAST(vac.new_vaccination AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_d) AS RollingPeopleVaccinated
      --,(RollingPeopleVaccinated/population)*100
FROM coviddeath AS dea
JOIN covidvaccination AS vac
ON dea.location = vac.location
AND dea.date_d = vac.date_d
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

--USING common table expression(CTE)

WITH popvsvac (continent, location, date_d, populations, new_vaccination, RollingPeopleVaccinated)
AS 
(
SELECT
dea.continent,
dea.date_d,
dea.location,
dea.population,
vac.new_vaccination,
SUM(CAST(vac.new_vaccination AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_d) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM coviddeath AS dea
JOIN covidvaccination AS vac
ON dea.location = vac.location
AND dea.date_d = vac.date_d
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3
)
SELECT *
FROM popvsvac

--Using Temporary Table to perform Calculation on PARTITION BY in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date_D date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT
dea.continent,
dea.date_d,
dea.location,
dea.population,
vac.new_vaccination,
SUM(CAST(vac.new_vaccination AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_d) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM coviddeath AS dea
JOIN covidvaccination AS vac
ON dea.location = vac.location
AND dea.date_d = vac.date_d
--WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

--creating view for data storing to do visualiztions lateron

CREATE VIEW percentpopulationvaccinated AS
SELECT
dea.continent,
dea.date_d,
dea.location,
dea.population,
vac.new_vaccination,
SUM(CAST(vac.new_vaccination AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_d) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM coviddeath AS dea
JOIN covidvaccination AS vac
ON dea.location = vac.location
AND dea.date_d = vac.date_d
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3;